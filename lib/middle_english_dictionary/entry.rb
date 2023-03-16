require "middle_english_dictionary/entry/class_methods"
require "nokogiri"
require "middle_english_dictionary/xml_utilities"
require "middle_english_dictionary/entry/orth"
require "middle_english_dictionary/entry/sense"
require "middle_english_dictionary/entry/sensegrp"
require "middle_english_dictionary/entry/note"
require "middle_english_dictionary/entry/supplement"
require "middle_english_dictionary/external_dictionary_link"
require "representable/json"

module MiddleEnglishDictionary
  class Entry
    module SenseStuffHierarchy
      # A recursive mechanism to fill teh "sensestuff" in the SENSE(GRP)
      # section
      #
      def self.sense_hierarchy(entry_id, nokonode)
        nokonode.xpath(ENTRY_XPATHS[:sense_stuff]).map do |n|
          case n.name
          when "SENSEGRP"
            SenseGrp.new_from_nokonode(n, entry_id: entry_id)
          when "SENSE"
            Sense.new_from_nokonode(n, entry_id: entry_id)
          when "NOTE"
            Note.new_from_nokonode(n, entry_id: entry_id)
          when "SUPPLEMENT"
            Supplement.new_from_nokonode(n, entry_id: entry_id)
          else
            raise "Shouldn't be getting a #{n.name} in sensestuff array"
          end
        end
      end
    end

    # extend MiddleEnglishDictionary::Entry::SenseStuff
    extend Entry::ClassMethods
    ROOT_XPATHS = {
      entry: "/MED/ENTRYFREE"
    }.freeze

    ENTRY_XPATHS = {
      hdorth: "FORM/HDORTH",
      other_orth: "FORM/ORTH",
      pos_facet: "FORM/POS/PS/@EXPAN",
      pos: "FORM/POS",
      etym: "ETYM",
      etym_languages: "ETYM/LANG/LG/@EXPAN",
      sense: "SENSE",
      sense_anywhere: "//SENSE",
      sensegrp: "SENSEGRP",
      sense_stuff: "SENSE|SENSEGRP|NOTE|SUPPLEMENT"
    }.freeze

    attr_accessor :headwords
    attr_accessor :source
    attr_accessor :id
    attr_accessor :sequence
    attr_accessor :orths
    attr_accessor :xml
    attr_accessor :etym_xml
    attr_accessor :etym_text
    attr_accessor :etym_languages
    attr_accessor :pos
    attr_accessor :pos_facet
    attr_accessor :senses
    attr_accessor :notes
    attr_accessor :supplements
    attr_accessor :oedlinks
    attr_accessor :doelinks

    # The "right" way to do this with Representable is...well, I'm not sure
    # what it is. I'm just going to recreate it from the raw XML every time
    # I read it, because while it's strikingly inefficient and makes me want
    # to shower, it'll work and it's good enough for now. See
    # def sensestuff, below

    attr_accessor :sensestuff

    def self.new_from_nokonode(root_nokonode, source: nil)
      MiddleEnglishDictionary::XMLUtilities.case_raise_all_tags!(root_nokonode)

      entry_nokonode = root_nokonode.at(ROOT_XPATHS[:entry])

      entry = new
      entry.source = source ? Pathname.new(source).basename : :io
      entry.xml = entry_nokonode.to_xml

      entry.id = entry_nokonode.attr("ID")
      entry.sequence = entry_nokonode.attr("SEQ").to_i

      entry.headwords = entry.derive_headwords(entry_nokonode)
      entry.orths = entry.derive_orths(entry_nokonode)

      if (etym_node = entry_nokonode.at(ENTRY_XPATHS[:etym]))
        entry.etym_xml = etym_node.to_xml
        entry.etym_text = etym_node.text
      end

      entry.etym_languages = entry_nokonode.xpath(ENTRY_XPATHS[:etym_languages]).map(&:value)

      entry.pos = entry_nokonode.at(ENTRY_XPATHS[:pos]).text
      entry.pos_facet = entry_nokonode.xpath(ENTRY_XPATHS[:pos_facet]).map(&:value)

      entry.senses = entry_nokonode.xpath(ENTRY_XPATHS[:sense_anywhere]).map { |sense| Sense.new_from_nokonode(sense, entry_id: entry.id) }
      entry.supplements = entry_nokonode.xpath("SUPPLEMENT").map { |supp| Supplement.new_from_nokonode(supp, entry_id: entry.id) }

      entry.notes = entry_nokonode.xpath("NOTE").map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip)

      # We want a set of all the sensegrp / sense / note stuff in one list, so they can be
      # displayed in order using XSLT. The data are *not* consistent enough to be able
      # to do it programmatically in a straightforward way.
      #

      entry.sensestuff = SenseStuffHierarchy.sense_hierarchy(entry.id, entry_nokonode)
      entry
    end

    # for easier debugging
    # @return [String] Nicely formatted XML of the whole entry
    def pretty_xml
      MiddleEnglishDictionary::XMLUtilities.pretty_xml(xml)
    end

    # Getting headwords and forms

    # @return [Array<String>] The "original" (in the paper dictionary) spelling(s)
    def original_headwords
      headwords.flat_map(&:origs).uniq
    end

    # @return [Array<String>] Headwords with a regularized spelling and no extra punctuation
    def regularized_headwords
      headwords.flat_map(&:regs)
    end

    # @return [Array<String>] All given spellings of the headword(s)
    def all_headword_forms
      headwords.flat_map(&:all_forms).uniq
    end

    # @return [Array<String>] Original presentation of the non-headword form(s)
    def original_orths
      orths.flat_map(&:origs).uniq
    end

    # @return [Array<String>] Regularized presentation of the non-headword form(s)
    def regularized_orths
      orths.flat_map(&:regs)
    end

    # @return [Array<String>] All given spellings (original and regular) of the non-headwords
    def all_orth_forms
      orths.flat_map(&:all_forms).uniq
    end

    def all_original_forms
      original_headwords.concat(original_orths).uniq
    end

    def all_regularized_forms
      regularized_headwords.concat(regularized_orths).uniq
    end

    # @return [Array<String>] All given spellings (original and regular) of the entry
    def all_forms
      all_original_forms.concat(all_regularized_forms).uniq
    end

    # @private
    def derive_headwords(entry_nokonode)
      entry_nokonode.xpath(ENTRY_XPATHS[:hdorth]).map { |w| Entry::Orth.new_from_nokonode(w, entry_id: id) }
    end

    # @private
    def derive_orths(entry_nokonode)
      entry_nokonode.xpath(ENTRY_XPATHS[:other_orth]).map { |w| Entry::Orth.new_from_nokonode(w, entry_id: id) }
    end

    # Citations from the sense(s) and the supplement(s)
    # @return [Array<Citation>] All the citations in the entry, from senses AND supplements
    def all_citations
      [senses, supplements].flatten.flat_map(&:egs).flat_map(&:citations)
    end

    # @return [Array<Bib>] All the bibs from all the citations
    def all_bibs
      all_citations.map(&:bib)
    end

    # @return [Array<Quote>] All the quotes from all the citations
    def all_quotes
      all_citations.map(&:quote)
    end

    # Return the Stencil object. A stencil is the citation proper: title,
    # date, manuscript, etc.
    # @return [Array<Stencil>] all the stencils from all the bibs
    def all_stencils
      all_bibs.map(&:stencil)
    end

    # Provide a JSON representation of this object and all its sub-objects
    # @return [String] json for this object
    def to_json
      EntryRepresenter.new(self).to_json
    end

    # Re-hydrate
    # @param [String] j Valid json as produced by #to_json
    # @return [Entry] A re-hydrated entry
    def self.from_json(j)
      EntryRepresenter.new(new).from_json(j)
    end

    # @param [String] f filename with Entry json in it
    # @return [Entry] A re-hydrated Entry
    def self.from_json_file(f)
      from_json(File.open(f, "r:utf-8").read)
    end
  end

  # Utility class to provide facilities to round trip between Entry
  # objects and json representations of those objects
  class EntryRepresenter < Representable::Decorator
    include Representable::JSON

    DECORATOR_FOR_CLASS = ->(klass) do
      Kernel.const_get(klass.to_s + "Representer")
    end

    property :id
    property :source
    property :sequence
    property :xml
    property :etym_xml
    property :etym_text
    property :etym_languages

    property :pos
    property :pos_facet

    property :oedlinks, decorator: MiddleEnglishDictionary::ExternalDictionaryLinkRepresenter, class: MiddleEnglishDictionary::ExternalDictionaryLink
    property :doelinks, decorator: MiddleEnglishDictionary::ExternalDictionaryLinkRepresenter, class: MiddleEnglishDictionary::ExternalDictionaryLink

    property :notes

    collection :headwords, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :orths, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :senses, decorator: Entry::SenseRepresenter, class: Entry::Sense
    collection :supplements, decorator: Entry::SupplementRepresenter, class: Entry::Supplement

    # Representable is weird in that it doesn't support mixed-class arrays
    # in an easy way. Here, we choose the decorator based on the class + 'Representer',
    # and the parsed-into class based on the stored 'objclass' property of
    # the json representation
    collection :sensestuff,
      decorator: ->(options) { DECORATOR_FOR_CLASS.call(options[:input].class) },
      class: ->(options) do
        begin
          Kernel.const_get options[:fragment]["objclass"]
        rescue => e
          require "pry"
          binding.pry
        end
      end
  end
end
