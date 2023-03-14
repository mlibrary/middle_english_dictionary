module MiddleEnglishDictionary
  module Collection
    class HashArray
      include Enumerable

      def initialize(&blk)
        @h = {}
        if blk
          instance_eval(&blk) # rubocop:disable Lint/Void
        end
        self # rubocop:disable Lint/Void
      end

      def keys
        @h.keys
      end

      def []=(k, v)
        @h[k] = v
      end

      def [](k)
        @h[k]
      end

      def each
        return enum_for(:each) unless block_given?
        @h.values.each { |v| yield v }
      end

      def each_pair
        return enum_for(:each_pair) unless block_given?
        @h.each_pair { |k, v| yield [k, v] }
      end
    end
  end
end
