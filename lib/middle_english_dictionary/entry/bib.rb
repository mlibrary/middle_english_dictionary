require_relative 'stencil'

module MiddleEnglishDictionary
  class Entry
    # A Bib is just a stencil. Stored as a unit because we need to hang onto
    # the XML
    class Bib

      attr_accessor :stencil, :xml, :entry_id

      def self.new_from_nokonode(nokonode, entry_id: nil)
        stencil_node = nokonode.at('STNCL')
        bib = self.new
        bib.entry_id = entry_id
        bib.stencil     = Stencil.new_from_nokonode(stencil_node, entry_id: entry_id) if stencil_node
        bib.xml         = nokonode.to_xml

        bib
      end
    end

  end
end


