require_relative "stencil"
require "representable/json"

module MiddleEnglishDictionary
  class Entry
    # A Bib is just a stencil. Stored as a unit because we need to hang onto
    # the XML
    class Bib
      attr_accessor :stencil, :scope, :entry_id, :notes

      def self.new_from_nokonode(nokonode, entry_id: nil)
        stencil_node = nokonode.at("STNCL")
        bib = new
        bib.entry_id = entry_id
        bib.stencil = Stencil.new_from_nokonode(stencil_node, entry_id: entry_id)
        bib.scope = nokonode.xpath("SCOPE").map(&:text).first
        bib.notes = nokonode.xpath("NOTE").map(&:text).map { |x| x.gsub(/[\s\n]+/, " ") }.map(&:strip)
        bib
      end
    end

    class BibRepresenter < Representable::Decorator
      include Representable::JSON

      property :scope
      property :entry_id
      property :stencil, decorator: StencilRepresenter, class: Stencil
      property :notes
    end
  end
end
