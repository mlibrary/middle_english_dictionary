require "middle_english_dictionary/entry/class_methods"
require_relative "eg"
require "representable/json"

module MiddleEnglishDictionary
  class Entry
    class Sense
      extend Entry::ClassMethods

      attr_accessor :xml, :definition_xml, :definition_text,
        :discipline_usages, :grammatical_usages,
        :egs, :sense_number, :entry_id, :notes,
        :sensegrp_number, :sensestuff

      def self.new_from_nokonode(nokonode, entry_id: nil)
        sense = new
        sense.xml = nokonode.to_xml
        sense.definition_xml = nokonode.xpath("DEF").map(&:to_xml).join("\n")
        sense.definition_text = nokonode.xpath("DEF").map(&:text).join("\n")
        sense.sense_number = (nokonode.attr("N") || 1).to_s

        sense.entry_id = entry_id
        sense.discipline_usages = sense.get_discipline_usages(nokonode)

        sense.egs = nokonode.css("EG").map { |eg| EG.new_from_nokonode(eg, entry_id: entry_id) }

        sense.notes = nokonode.xpath("NOTE").map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip)

        # We'll make a list of all the "sense" things (stuff that appears within a SENSE or
        # SENSEGRP) so we can provide them to the display in the correct order.
        #
        sense.sensestuff = SenseStuffHierarchy.sense_hierarchy(entry_id, nokonode)

        sense
      end

      def get_discipline_usages(nokonode)
        nokonode.xpath('//DEF/USG[@TYPE="FIELD"]/@EXPAN').map(&:value).map(&:capitalize).uniq
      end
    end

    class SenseRepresenter < Representable::Decorator
      include Representable::JSON

      # Representable is weird in that it doesn't support mixed-class arrays
      # in an easy way. Have to do some messing around, including storing the
      # class of the object in the representation (json, in our case). It's
      # ignored (via `skip_class`) when parsing back into an object from the
      # json.

      property :objclass, getter: ->(represented:, **) { represented.class.to_s }, skip_parse: true

      property :entry_id
      property :definition_xml
      property :definition_text
      property :sense_number
      property :sensegrp_number
      property :discipline_usages
      collection :egs, decorator: EGRepresenter, class: EG
      property :notes
    end
  end
end
