require 'nokogiri'
require 'middle_english_dictionary/oed_link'
require 'middle_english_dictionary/collection/hash_array'
require 'pathname'

module MiddleEnglishDictionary
  module Collection
    class OEDLinkSet < HashArray

      def self.from_nokonode(node)
        err     = File.open('oed_errors.txt', 'w:utf-8')
        oedlist = node.xpath('/links/link').reduce(self.new) do |acc, linknode|
          oedlink = MiddleEnglishDictionary::OEDLink.new_from_nokonode(linknode)
          if [oedlink.med_id, oedlink.oed_id].all? {|x| x =~ /[A-Za-z0-9]/}
            acc[oedlink.med_id] = oedlink
          else
            err.puts linknode.to_xml
          end
          acc
        end
        oedlist
      end

      def self.from_xml(xml)
        self.from_nokonode(Nokogiri::XML(xml))
      end

      def self.from_xml_file(filename)
        xml     = File.read(filename).encode("UTF-8", "ISO-8859-1")
        self.from_xml(xml)
      end
    end
  end
end

