require "middle_english_dictionary/entry/class_methods"
require "representable/json"

module MiddleEnglishDictionary
  class Entry
    class Orth
      extend Entry::ClassMethods

      attr_accessor :regs, :origs, :entry_id, :notes

      def initialize(regs: [], origs: [], entry_id: nil, notes: [])
        @entry_id = entry_id
        @regs = regs
        @origs = origs
      end

      def all_forms
        origs.concat(regs).uniq
      end

      def self.new_from_nokonode(nokonode, entry_id: nil)
        regs = nokonode.xpath("REG").map(&:text)
        origs = nokonode.xpath("ORIG").map(&:text)
        notes = nokonode.xpath("NOTE").map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip)
        new(regs: regs, origs: origs, entry_id: entry_id, notes: notes)
      end
    end

    class OrthRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :regs
      property :origs
      property :notes
    end
  end
end
