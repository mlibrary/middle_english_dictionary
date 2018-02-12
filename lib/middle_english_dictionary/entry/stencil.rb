module MiddleEnglishDictionary
  class Entry
    # A Stencil is a a bibliographic reference. Here we pull
    # out, if there are any, highlighted phrases, the title, and the
    # non-parsed date.
    #
    # We also have the "rid", a unique identifier used to cross-reference
    # to the hyperbib
    class Stencil

      attr_accessor :rid, :date, :highlighted_phrases, :title, :ms, :entry_id

      def self.new_from_nokonode(nokonode, entry_id: nil)
        stencil = self.new
        stencil.entry_id = entry_id

        stencil.rid = nokonode.attr('RID')
        stencil.date = nokonode.xpath('DATE').map(&:text).first
        stencil.highlighted_phrases = nokonode.css('HI').map(&:text).uniq
        stencil.title = nokonode.xpath('TITLE').map(&:text).first
        stencil.ms = nokonode.xpath('MS').map(&:text).first

        stencil
      end

    end
  end
end
