require "middle_english_dictionary/errors"

module MiddleEnglishDictionary
  class Entry
    module ClassMethods
      def new_from_xml(xml, source: nil)
        node = Nokogiri::XML(xml) {|conf| conf.strict}
        new_from_nokonode(Nokogiri::XML(xml), source: source)
      rescue Nokogiri::XML::SyntaxError => e
        raise MiddleEnglishDictionary::InvalidXML.new("Invalid XML in #{source}: #{e.message}")
      end


      def new_from_xml_file(filename)
        raise MiddleEnglishDictionary::FileNotFound.new("File '#{filename}' not found") unless File.exists?(filename)
        raise MiddleEnglishDictionary::FileEmpty.new("File '#{filename}' is empty") if File.empty?(filename)
        new_from_xml(File.open(filename, 'r:utf-8').read, source: filename)
      end
    end
  end
end
