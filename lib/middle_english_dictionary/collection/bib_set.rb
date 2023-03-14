require "nokogiri"
require_relative "../bib"
require_relative "ms_names"

module MiddleEnglishDictionary
  module Collection
    class BibSet
      include Enumerable

      def initialize(filename: nil, nokonode: nil)
        raise "Need to provide either a filename or a nokonode" unless filename || nokonode

        nokonode ||= Nokogiri::XML(File.open(filename, "r:utf-8").read)

        # Run one: make all the bibs
        @bibs = nokonode.xpath("/HYPERMED/ENTRY").each_with_object({}) do |n, h|
          b = MiddleEnglishDictionary::Bib.new_from_nokonode(n)
          h[b.id] = b
        end

        add_ms_full_titles!(nokonode)
      end

      def each
        return enum_for(:each) unless block_given?
        @bibs.each_pair do |k, v|
          yield v
        end
      end

      def each_pair
        return enum_for(:each) unless block_given?
        @bibs.each_pair do |k, v|
          yield [k, v]
        end
      end

      def [](k)
        @bibs[k]
      end

      def add_ms_full_titles!(nokonode)
        names = MSNames.new_from_nokonode(nokonode)
        each do |b|
          b.manuscripts.each do |ms|
            ms.title = names[ms.ref].title
            ms.title_xml = names[ms.ref].title_xml
          end
        end
      end
    end
  end
end
