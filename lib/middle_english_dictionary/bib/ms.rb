module MiddleEnglishDictionary
  class Bib
    class MS
      # <MS REF="CORP-O"><CITE>155</CITE><LALME>vol. 1. 152. Lincs.</LALME></MS>
      attr_accessor :ref,
                    :pref,
                    :cite,
                    :lalme,
                    :lalme_regions
                    :title

      def initialize(nokonode)
        @ref = nokonode.attr('REF')
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
        @lalme = if l = nokonode.xpath('LALME').map(&:text).first and !l.empty?
                   l
                 else
                   nil
                 end
        @lalme_regions = nokonode.xpath('LALME/REGION').map{|x| x.attr('EXPAN')}
      end
    end
  end
end
