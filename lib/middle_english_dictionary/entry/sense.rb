require 'middle_english_dictionary/entry/class_methods'
require_relative 'eg'
require 'representable/json'

module MiddleEnglishDictionary
  class Entry
    class Sense
      extend Entry::ClassMethods

      attr_accessor :xml, :definition_xml, :definition_text,
                    :discipline_usages, :grammatical_usages,
                    :egs, :sense_number, :entry_id, :notes


      def self.new_from_nokonode(nokonode, entry_id: nil)

        sense                 = self.new
        sense.xml             = nokonode.to_xml
        sense.definition_xml  = nokonode.xpath('DEF').map(&:to_xml).join("\n")
        sense.definition_text = nokonode.xpath('DEF').map(&:text).join("\n")
        sense.sense_number    = (nokonode.attr('N') || 1).to_s

        sense.entry_id = entry_id
        sense.discipline_usages  = sense.get_discipline_usages(nokonode)

        sense.egs = nokonode.css('EG').map {|eg| EG.new_from_nokonode(eg, entry_id: entry_id)}

        sense.notes = nokonode.xpath('NOTE').map(&:text).map{|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)

        sense
      end

      def get_discipline_usages(nokonode)
        nokonode.xpath('//DEF/USG[@TYPE="FIELD"]').map {|n| n.attr('EXPAN')}.map(&:capitalize).uniq
      end

    end

    class SenseRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :definition_xml
      property :definition_text
      property :sense_number
      property :discipline_usages
      collection :egs, decorator: EGRepresenter, class: EG
      property :notes

    end

  end
end
