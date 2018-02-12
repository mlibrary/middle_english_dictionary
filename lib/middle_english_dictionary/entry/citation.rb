require_relative "bib"
require_relative "quote"

module MiddleEnglishDictionary
  class Entry

    # An individual citation always has a bib entry and a quote. It may
    # also have integer-ized guesses at the years the work was created
    # (cd) and the year this particular manuscript is from (md)
    class Citation

      attr_accessor :quote, :cd, :md, :bib, :xml, :entry_id

      # @param [Nokogiri::XML::Element] nokonode The nokogiri node for this element
      def self.new_from_nokonode(nokonode, entry_id: nil)
        eg = self.new
        eg.entry_id = entry_id
        eg.md    = nokonode.attr('MD') && nokonode.attr('MD').to_i
        eg.cd    = nokonode.attr('CD') && nokonode.attr('CD').to_i
        eg.quote = Quote.new_from_nokonode(nokonode.at('Q'), entry_id: entry_id)
        eg.bib   = Bib.new_from_nokonode(nokonode.at('BIBL'), entry_id: entry_id)

        eg
      end
    end
  end
end

