require "middle_english_dictionary/entry"
require "middle_english_dictionary/collection/hash_array"

module MiddleEnglishDictionary
  module Collection
    class EntrySet < HashArray
      def load_dir_of_json_files(rawdir)
        dir = Pathname(rawdir)
        dir.children.select { |x| x.to_s =~ /MED.*\.json\Z/ }.each do |f|
          entry = MiddleEnglishDictionary::Entry.from_json_file(f)
          self[entry.id] = entry
        end
      end

      def add_oeds_from_file(filename)
        oeds = MiddleEnglishDictionary::Collection::OEDLinkSet.from_xml_file(filename)
        oeds.each_pair { |med_id, links| self[med_id].oed_links = links }
      end

      def add_does_from_file(filename)
        does = MiddleEnglishDictionary::Collection::OEDLinkSet.from_xml_file(filename)
        does.each_pair { |med_id, links| self[med_id].doe_links = links }
      end
    end
  end
end
