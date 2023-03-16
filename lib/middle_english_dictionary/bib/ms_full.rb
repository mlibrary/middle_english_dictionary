module MiddleEnglishDictionary
  class Bib
    class MSFull
      attr_accessor :code, :title, :title_xml

      def initialize(code = nil, title = nil, title_xml = nil)
        @code = code
        @title = title
        @title_xml = title_xml
      end
    end
  end
end
