require 'middle_english_dictionary/entry/class_methods'
require 'nokogiri'
require 'middle_english_dictionary/xml_utilities'
require 'middle_english_dictionary/entry/orth'
require 'middle_english_dictionary/entry/sense'
require 'middle_english_dictionary/entry/supplement'
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
                  :etym, :etym_languages, :pos_raw, :senses, :notes,
                  :supplements, :oedlink

    def self.new_from_nokonode(root_nokonode, source: nil)
      MiddleEnglishDictionary::XMLUtilities.case_raise_all_tags!(root_nokonode)

      entry_nokonode = root_nokonode.at(ROOT_XPATHS[:entry])

      entry        = self.new
      entry.source = source
      entry.xml    = entry_nokonode.to_xml

      entry.id       = entry_nokonode.attr('ID')
      entry.sequence = entry_nokonode.attr('SEQ').to_i

      entry.headwords = entry.derive_headwords(entry_nokonode)
      entry.orths     = entry.derive_orths(entry_nokonode)

      entry.etym           = if etym_node = entry_nokonode.at(ENTRY_XPATHS[:etym])
                               etym_node.to_xml
                             else
                               nil
                             end
      entry.etym_languages = entry_nokonode.xpath(ENTRY_XPATHS[:etym_languages]).map(&:text).map(&:upcase)

      entry.pos_raw = entry_nokonode.at(ENTRY_XPATHS[:pos]).text

      entry.senses      = entry_nokonode.xpath('SENSE').map {|sense| Sense.new_from_nokonode(sense, entry_id: entry.id)}
      entry.supplements = entry_nokonode.xpath('SUPPLEMENT').map {|supp| Supplement.new_from_nokonode(supp, entry_id: entry.id)}

      entry.notes = entry_nokonode.xpath('NOTE').map(&:text).map{|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)
      entry
    end


    # Getting headwords and forms

    def original_headwords
      headwords.flat_map(&:origs).uniq
    end

    def regularized_headwords
      headwords.flat_map(&:regs)
    end

    def all_headword_forms
      headwords.flat_map(&:all_forms).uniq
    end

    def original_orths
      orths.flat_map(&:origs).uniq
    end

    def regularized_orths
      orths.flat_map(&:regs)
    end

    def all_orth_forms
      orths.flat_map(&:all_forms).uniq
    end

    def all_original_forms
      original_headwords.concat(original_orths).uniq
    end

    def all_regularized_forms
      regularized_headwords.concat(regularized_orths).uniq
    end

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
    def normalized_pos_raw(pos_raw = self.pos_raw)
      pos_raw.downcase.gsub(/\s*\(\d\)\s*\Z/, '').gsub(/\.+\s*\Z/, '').gsub(/\./, ' ')
    end

    # Citations from the sense(s) and the supplement(s)
    def all_citations
      [senses, supplements].flatten.flat_map(&:egs).flat_map(&:citations)
    end

    def all_quotes
      all_citations.map(&:quote)
    end


  end

  class EntryRepresenter < Representable::Decorator
    include Representable::JSON

    property :id
    property :source
    property :sequence
    property :xml
    property :etym
    property :etym_languages
    property :pos_raw
    property :oedlink

    property :notes

    collection :headwords, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :orths, decorator: Entry::OrthRepresenter, class: Entry::Orth
    collection :senses, decorator: Entry::SenseRepresenter, class: Entry::Sense
    collection :supplements, decorator: Entry::SupplementRepresenter, class: Entry::Supplement
  end
end
