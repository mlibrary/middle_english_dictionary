require 'middle_english_dictionary/entry/constructors'

module MiddleEnglishDictionary
  class Entry
    class Orth

      extend Entry::Constructors

      attr_accessor :regs, :origs, :entry_id

      def initialize(regs: [], origs: [], entry_id: nil)
        @entry_id = entry_id
        @regs = regs
        @origs = origs
      end

      def all_forms
        origs.concat(regs).uniq
      end

      def self.new_from_nokonode(node, entry_id: nil)
        regs = node.xpath('REG').map(&:text)
        origs = node.xpath('ORIG').map(&:text)
        self.new(regs: regs, origs: origs, entry_id: entry_id)
      end

    end
  end
end
