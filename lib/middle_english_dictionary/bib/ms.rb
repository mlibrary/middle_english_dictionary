module MiddleEnglishDictionary
  class Bib
    class MS
      # <MS REF="CORP-O"><CITE>155</CITE><LALME>vol. 1. 152. Lincs.</LALME></MS>
      attr_accessor :ref,
                    :pref,
                    :cite,
                    :lalme

      def initialize(nokonode)
        @ref = nokonode.attr('REF')


      end

    end
  end
end
