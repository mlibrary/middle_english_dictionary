module MiddleEnglishDictionary
  class Bib
    class MS
      # <MS REF="CORP-O"><CITE>155</CITE><LALME>vol. 1. 152. Lincs.</LALME></MS>
      attr_accessor :ref,
                    :pref,
                    :cite,
                    :lalme, :lalme_xml,:lalme_regions,
                    :laeme, :laeme_xml,:laeme_regions,
                    :title,
                    :title_xml,
                    :xml


      def initialize(nokonode = nil)
        return unless nokonode
        @xml  = nokonode.to_xml
        @ref  = nokonode.attr('REF')
        @pref = case nokonode.attr('PREF')
                when 'Y'
                  :all
                when 'PART'
                  :part
                else
                  nil
                end
        @cite = if c = nokonode.xpath('CITE').map(&:text).first and !c.empty?
                  c
                else
                  nil
                end

        l     = nokonode.xpath('LALME')
        if !l.empty?
          @lalme     = l.map(&:text)
          @lalme_xml = l.map(&:to_xml)
        end
        @lalme_regions = nokonode.xpath('LALME/REGION').map {|x| x.attr('EXPAN')}

        l     = nokonode.xpath('LAEME')
        if !l.empty?
          @laeme     = l.map(&:text)
          @laeme_xml = l.map(&:to_xml)
        end
        @laeme_regions = nokonode.xpath('LAEME/REGION').map {|x| x.attr('EXPAN')}
      end


      def pref_all?
        @pref == :all
      end


      def pref_part?
        @pref == :part
      end


      def pref_any?
        pref_all? or pref_part?
      end
    end

    class MSRepresenter < Representable::Decorator
      include Representable::JSON

      property :ref
      property :pref
      property :cite

      property :lalme
      property :lalme_xml
      property :lalme_regions

      property :laeme
      property :laeme_xml
      property :laeme_regions

      property :title
      property :title_xml
      property :xml
    end


  end
end
