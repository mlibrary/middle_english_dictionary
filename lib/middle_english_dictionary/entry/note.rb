require "representable/json"
require_relative "class_methods"

module MiddleEnglishDictionary
  class Entry
    # A "Note" is just note text, created as an object for consistency
    # of interface
    class Note
      extend Entry::ClassMethods

      attr_accessor :text, :xml, :entry_id

      def self.new_from_nokonode(nokonode, entry_id: nil)
        note = new
        note.entry_id = entry_id
        note.text = nokonode.map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip).first
        note.xml = nokonode.to_xml
        note
      end
    end

    class NoteRepresenter < Representable::Decorator
      include Representable::JSON

      # Representable is weird in that it doesn't support mixed-class arrays
      # in an easy way. Have to do some messing around, including storing the
      # class of the object in the representation (json, in our case). It's
      # ignored (via `skip_class`) when parsing back into an object from the
      # json.
      property :objclass, getter: ->(represented:, **) { represented.class.to_s }, skip_parse: true

      property :entry_id
      property :xml
      property :text
    end
  end
end
