require 'middle_english_dictionary/entry/class_methods'
require 'nokogiri'
require 'middle_english_dictionary/xml_utilities'
require 'middle_english_dictionary/entry/orth'
require 'middle_english_dictionary/entry/sense'
require 'middle_english_dictionary/entry/supplement'
require 'middle_english_dictionary/oed_link'
require 'representable/json'

module MiddleEnglishDictionary

  # For notes, we'll just store the xml and the text and not worry about it
  Note = Struct.new(:xml, :text)

  class Entry

    extend Entry::ClassMethods
    ROOT_XPATHS = {
      entry: '/MED/ENTRYFREE',
    }

    ENTRY_XPATHS = {
      hdorth:         'FORM/HDORTH',
      other_orth:     'FORM/ORTH',
      pos:            'FORM/POS',
      etym:           'ETYM',
      etym_languages: 'ETYM/LANG',
      sense:          'SENSE'
    }


    attr_accessor :headwords, :source, :id, :sequence, :orths, :xml,
                  :etym_xml, :etym_languages, :pos_raw, :senses, :notes,
                  :supplements, :oedlink

    def self.new_from_nokonode(root_nokonode, source: nil)
      MiddleEnglishDictionary::XMLUtilities.case_raise_all_tags!(root_nokonode)

      entry_nokonode = root_nokonode.at(ROOT_XPATHS[:entry])

      entry        = self.new
      entry.source = source ? Pathname.new(source).basename : :io
      entry.xml    = entry_nokonode.to_xml

      entry.id       = entry_nokonode.attr('ID')
      entry.sequence = entry_nokonode.attr('SEQ').to_i

      entry.headwords = entry.derive_headwords(entry_nokonode)
      entry.orths     = entry.derive_orths(entry_nokonode)

      entry.etym_xml       = if etym_node = entry_nokonode.at(ENTRY_XPATHS[:etym])
                               etym_node.to_xml
                             else
                               nil
                             end
      entry.etym_languages = entry_nokonode.xpath(ENTRY_XPATHS[:etym_languages]).map(&:text).map(&:upcase)

      entry.pos_raw = entry_nokonode.at(ENTRY_XPATHS[:pos]).text

      entry.senses      = entry_nokonode.xpath('SENSE').map {|sense| Sense.new_from_nokonode(sense, entry_id: entry.id)}
      entry.supplements = entry_nokonode.xpath('SUPPLEMENT').map {|supp| Supplement.new_from_nokonode(supp, entry_id: entry.id)}

      entry.notes = entry_nokonode.xpath('NOTE').map(&:text).map {|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)
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
      entry_nokonode.xpath(ENTRY_XPATHS[:hdorth]).map {|w| Entry::Orth.new_from_nokonode(w, entry_id: id)}
    end

    # @private
    def derive_orths(entry_nokonode)
      entry_nokonode.xpath(ENTRY_XPATHS[:other_orth]).map {|w| Entry::Orth.new_from_nokonode(w, entry_id: id)}
    end


    # Part of speech
    #
    # @param [String] pos_raw The raw (unfixed) part of speech
    # @return [String] A hopefully normalized version (e.g., '(n.(1))' should just become 'n')
    def normalized_pos_raw(pos_raw = self.pos_raw)
      pos_raw.downcase.gsub(/\s*\(\d\)\s*\Z/, '').gsub(/\.+\s*\Z/, '').gsub(/\./, ' ')
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
    # @param [String] Valid json as produced by #to_json
    # @return [Entry] A re-hydrated entry
    def self.from_json(j)
      EntryRepresenter.new(self.new).from_json(j)
    end

    # @param [String] filename with Entry json in it
    # @return [Entry] A re-hydrated Entry
    def self.from_json_file(f)
      self.from_json(File.open(f, 'r:utf-8').read)
    end

  end

  # Utility class to provide facilities to round trip between Entry
  # objects and json representations of those objects
  class EntryRepresenter < Representable::Decorator
    include Representable::JSON

    property :id
    property :source
    property :sequence
    property :xml
    property :etym_xml
    property :etym_languages
    property :pos_raw
    property :oedlink, decorator: MiddleEnglishDictionary::OEDLinkRepresenter, class: MiddleEnglishDictionary::OEDLink

    property :notes

    collection :headwords, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :orths, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :senses, decorator: Entry::SenseRepresenter, class: Entry::Sense
    collection :supplements, decorator: Entry::SupplementRepresenter, class: Entry::Supplement
  end
end
