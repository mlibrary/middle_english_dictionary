module MiddleEnglishDictionary
  module Collection
    class HashArray
      include Enumerable

      def initialize(&blk)
        @h = {}
        if block_given?
          self.instance_eval &blk
        end
        self
      end

      def []=(k, v)
        @h[k] = v
      end

      def [](k)
        @h[k]
      end

      def each
        return enum_for(:each) unless block_given?
        @h.values.each {|v| yield v}
      end
    end
  end
end
