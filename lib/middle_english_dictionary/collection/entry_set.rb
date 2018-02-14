require 'middle_english_dictionary/entry'
require 'middle_english_dictionary/collection/hash_array'

module MiddleEnglishDictionary
  module Collection
    class EntrySet < HashArray

      def load_dir_of_json_files(rawdir)
        dir = Pathname(rawdir)
        dir.children.select{|x| x.to_s =~ /MED.*\.json\Z/}.each do |f|
          entry = MiddleEnglishDictionary::Entry.from_json_file(f)
          self[entry.id] = entry
        end
      end


    end
  end
end
