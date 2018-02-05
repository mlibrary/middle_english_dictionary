module MiddleEnglishDictionary
  class Entry
    class Orth
      attr_accessor :regs, :origs

      def initialize(regs: [], origs: [])
        @regs = regs
        @origs = origs
      end

      def all_forms
        regs.concat(origs).uniq
      end

      def self.new_from_nokonode(node)
        regs = node.xpath('REG').map(&:text)
        origs = node.xpath('ORIG').map(&:text)
        self.new(regs: regs, origs: origs)
      end

    end
  end
end
