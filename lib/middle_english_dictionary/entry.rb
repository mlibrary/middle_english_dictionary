require 'nokogiri'
require 'middle_english_dictionary/xml_utilities'
require 'middle_english_dictionary/entry/orth'
module MiddleEnglishDictionary

  class Entry

    ROOT_XPATHS = {
        entry: '/MED/ENTRYFREE',
    }

    ENTRY_XPATHS = {
        hdorth: 'FORM/HDORTH',
        other_orth: 'FORM/ORTH',
        part_of_speech: 'FORM/POS',
        etymology: 'ETYM',
        sense: 'SENSE'
    }


    attr_accessor :headwords, :source

    def self.new_from_nokonode(root_nokonode, source: nil)
      MiddleEnglishDictionary::XMLUtilities.case_raise_all_tags!(root_nokonode)

      nokonode = root_nokonode.at(ROOT_XPATHS[:entry])
      entry = self.new
      entry.source = source
      entry.headwords = nokonode.xpath(ENTRY_XPATHS[:hdorth]).map{|hw| Entry::Orth.new_from_nokonode(hw)}

      entry
    end



    def self.new_from_xml_file(filename)
      new_from_xml(File.open(filename, 'r:utf-8').read, source: filename)
    end

    def self.new_from_xml(xml, source: nil)
      new_from_nokonode(Nokogiri::XML(xml), source: source)
    end



  end

end
