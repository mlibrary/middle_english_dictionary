require 'representable/json'

module MiddleEnglishDictionary
  class Entry
    # A Stencil is a a bibliographic reference. Here we pull
    # out, if there are any, highlighted phrases, the title, and the
    # non-parsed date.
    #
    # We also have the "rid", a unique identifier used to cross-reference
    # to the hyperbib
    class Stencil

      attr_accessor :rid, :date, :highlighted_phrases,
                    :author,:title, :ms, :entry_id, :notes, :xml

      def self.new_from_nokonode(nokonode, entry_id: nil)
        stencil          = self.new
        stencil.entry_id = entry_id
        stencil.xml      = nokonode.to_xml

        stencil.author              = nokonode.xpath('AUTHOR').map(&:text).first
        stencil.rid                 = nokonode.attr('RID')
        stencil.date                = nokonode.xpath('DATE').map(&:text).first
        stencil.highlighted_phrases = nokonode.css('HI').map(&:text).uniq
        stencil.title               = nokonode.xpath('TITLE').map(&:text)
        stencil.ms                  = nokonode.xpath('MS').map(&:text).first
        stencil.notes               = nokonode.xpath('NOTE').map(&:text).map{|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)
        stencil
      end

    end

    class StencilRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :xml

      property :rid
      property :date
      property :highlighted_phrases
      property :author
      property :title
      property :ms

      property :notes

    end
  end
end
