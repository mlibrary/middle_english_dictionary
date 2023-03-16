require_relative "bib"
require_relative "quote"
require "representable/json"
module MiddleEnglishDictionary
  class Entry
    # An individual citation always has a bib entry and a quote. It may
    # also have integer-ized guesses at the years the work was created
    # (cd) and the year this particular manuscript is from (md)
    class Citation
      attr_accessor :quote, :cd, :md, :bib, :xml, :entry_id, :notes, :text

      # @param [Nokogiri::XML::Element] nokonode The nokogiri node for this element
      def self.new_from_nokonode(nokonode, entry_id: nil)
        cite = new
        cite.entry_id = entry_id
        cite.md = nokonode.attr("MD") && nokonode.attr("MD").to_i
        cite.cd = nokonode.attr("CD") && nokonode.attr("CD").to_i
        cite.quote = Quote.new_from_nokonode(nokonode.at("Q"), entry_id: entry_id)
        cite.bib = Bib.new_from_nokonode(nokonode.at("BIBL"), entry_id: entry_id)
        cite.notes = nokonode.xpath("NOTE").map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip)
        cite.text = nokonode.text
        cite.xml = nokonode.to_xml
        cite
      end

      # Provide a JSON representation of this object and all its sub-objects
      # @return [String] json for this object
      def to_json
        CitationRepresenter.new(self).to_json
      end

      # Re-hydrate
      # @param [String] j Valid json as produced by #to_json
      # @return [Entry] A re-hydrated citation
      def self.from_json(j)
        CitationRepresenter.new(new).from_json(j)
      end
    end

    class CitationRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :md
      property :cd
      property :quote, decorator: QuoteRepresenter, class: Quote
      property :bib, decorator: BibRepresenter, class: Bib
      property :notes
      property :text
      property :xml
    end
  end
end
