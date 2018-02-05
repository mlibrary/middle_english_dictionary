require 'nokogiri'

module MiddleEnglishDictionary
  module XMLUtilities

    def self.case_raise_all_tags!(node)
      node.traverse {|node| node.name = node.name.upcase if node.class == Nokogiri::XML::Element}
      nil
    end


  end
end
