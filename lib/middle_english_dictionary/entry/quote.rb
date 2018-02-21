require 'representable/json'

module MiddleEnglishDictionary
  class Entry

    # A Quote can have a bunch of parts, almost all of them optional. At its
    # core, though, it's just a string of text with some inline markup that
    # we may or may not want to worry about
    #
    # All the attributes are just (often empty) arrays of text strings marked
    # up with the given tag
    class Quote
      attr_accessor :titles, :added, :ovars, :highlighted_phrases,
                    :text, :xml, :entry_id, :notes

      def self.new_from_nokonode(nokonode, entry_id: nil)
        q          = self.new
        q.entry_id = entry_id

        q.titles              = nokonode.xpath("TITLE").map(&:text).uniq
        q.highlighted_phrases = nokonode.xpath("HI").map(&:text).uniq
        q.text                = nokonode.text
        q.xml                 = nokonode.to_xml
        q.notes               = nokonode.xpath('NOTE').map(&:text).map{|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)
        q
      end

    end

    class QuoteRepresenter < Representable::Decorator
      include Representable::JSON

      property :entry_id
      property :titles
      property :highlighted_phrases
      property :text
      property :xml
      property :notes


    end

  end
end
