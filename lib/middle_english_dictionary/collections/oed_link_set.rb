require 'nokogiri'
require 'middle_english_dictionary/oed_link'
require 'middle_english_dictionary/collections/hash_array'
require 'pathname'

module MiddleEnglishDictionary
  module Collections
    class OEDLinkSet < HashArray

      def self.from_directory_of_xml_files(dirstring)
        err = File.open('errors.txt', 'w:utf-8')
        oedlist = self.new
        dir     = Pathname.new(dirstring)
        dir.children.select{|f| f.to_s =~ /links_.*\.xml/}.each do |f|
          puts "Working on #{f}"
          Nokogiri::XML(File.read(f)).xpath('/links/link').each do |linknode|
            oedlink                 = MiddleEnglishDictionary::OEDLink.new_from_nokonode(linknode)
            if [oedlink.med_id, oedlink.oed_id].all?{|x| x =~ /[A-Za-z0-9]/}
              oedlist[oedlink.med_id] = oedlink
            else
              err.puts linknode.to_xml
            end
          end
          puts oedlist.count

        end
        oedlist
      end
    end
  end
end
