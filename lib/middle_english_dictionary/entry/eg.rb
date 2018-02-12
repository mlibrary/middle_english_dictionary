require 'middle_english_dictionary/entry/constructors'
require_relative 'citation'
require 'representable/json'

module MiddleEnglishDictionary
  class Entry
    class EG

      attr_accessor :citations, :subdef_entry, :entry_id, :xml

      def self.new_from_nokonode(nokonode, entry_id: nil)
        eg              = self.new
        eg.xml          = nokonode.to_xml
        eg.subdef_entry = (nokonode.attr('N') || '').downcase
        eg.citations    = nokonode.xpath('CIT').map {|cit| Citation.new_from_nokonode(cit, entry_id: entry_id)}
        eg.entry_id     = entry_id

        eg
      end

      def quotes
        citations.flat_map(&:quote)
      end

    end

    class EGRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :subdef_entry
      property :xml
      collection :citations, decorator: CitationRepresenter, class: Citation

    end

  end
end
