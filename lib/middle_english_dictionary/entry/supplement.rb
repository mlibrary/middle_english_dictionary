require_relative 'eg'
require 'representable/json'

module MiddleEnglishDictionary
  class Entry
    class Supplement

      attr_accessor :egs, :notes, :entry_id, :xml


      def self.new_from_nokonode(nokonode, entry_id: nil)
        supp          = self.new
        supp.entry_id = entry_id
        supp.egs      = nokonode.css('EG').map {|eg| EG.new_from_nokonode(eg, entry_id: entry_id)}
        supp.notes    = nokonode.xpath('NOTE').map(&:text).map {|x| x.gsub(/[\s\n]+/, ' ')}.map(&:strip)
        supp.xml      = nokonode.to_xml
        supp
      end

    end

    class SupplementRepresenter < Representable::Decorator
      include Representable::JSON

      property :objclass, getter: ->(represented:, **) {represented.class.to_s}, skip_parse: true

      property :entry_id
      property :xml
      property :notes

      collection :egs, decorator: EGRepresenter, class: EG
    end

  end
end
