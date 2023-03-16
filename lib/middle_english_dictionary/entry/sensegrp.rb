require_relative "sense"
require_relative "class_methods"
require "representable/json"

module MiddleEnglishDictionary
  class Entry
    class SenseGrp
      extend Entry::ClassMethods

      attr_accessor :definition_xml, :definition_text, :sensegrp_number, :senses, :xml, :entry_id

      def self.new_from_nokonode(nokonode, entry_id: nil)
        sensegrp = new
        sensegrp.entry_id = entry_id
        sensegrp.xml = nokonode.to_xml
        sensegrp.sensegrp_number = nokonode.attr("N")
        sensegrp.definition_xml = nokonode.xpath("DEF").map(&:to_xml).join("\n")
        sensegrp.definition_text = nokonode.xpath("DEF").map(&:text).join("\n")
        sensegrp.senses = nokonode.xpath("SENSE").map { |s| Entry::Sense.new_from_nokonode(s, entry_id: entry_id) }
        sensegrp.senses.each { |s| s.sensegrp_number = sensegrp.sensegrp_number }
        sensegrp
      end
    end

    class SenseGrpRepresenter < Representable::Decorator
      include Representable::JSON

      # Representable is weird in that it doesn't support mixed-class arrays
      # in an easy way. Have to do some messing around, including storing the
      # class of the object in the representation (json, in our case). It's
      # ignored (via `skip_class`) when parsing back into an object from the
      # json.
      property :objclass, getter: ->(represented:, **) { represented.class.to_s }, skip_parse: true

      property :entry_id
      property :xml
      property :definition_xml
      property :definition_text
      property :sensegrp_number
      collection :senses, decorator: Entry::SenseRepresenter, class: Entry::Sense
    end
  end
end
