module MiddleEnglishDictionary
  class Entry
    module Constructors
      def new_from_xml(xml, source: nil)
        new_from_nokonode(Nokogiri::XML(xml), source: source)
      end

      def new_from_xml_file(filename)
        new_from_xml(File.open(filename, 'r:utf-8').read, source: filename)
      end
    end
  end
end
