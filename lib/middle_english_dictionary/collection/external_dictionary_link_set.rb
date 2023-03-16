require "nokogiri"
require "middle_english_dictionary/utilities"
require "middle_english_dictionary/external_dictionary_link"
require "middle_english_dictionary/collection/hash_array"
require "pathname"

module MiddleEnglishDictionary
  module Collection
    class ExternalDictionaryLinkSet < HashArray
      def self.from_nokonode(nokonode)
        nokonode.xpath("/links/link").each_with_object(new) do |linknode, new_set|
          raw_med_id = linknode.attr("sourceID")
          next unless raw_med_id.to_s.start_with?("MED")

          med_id = MiddleEnglishDictionary.normalize_med_id(raw_med_id)
          target_ids_string = linknode.attr("targetID")
          target_terms = new_set.get_terms(linknode)
          normalized = new_set.get_normalized_term(linknode)

          link = MiddleEnglishDictionary::ExternalDictionaryLink.new(med_id: med_id, normalized_term: normalized)
          link.add_valid_terms!(ids_string: target_ids_string, terms: target_terms)

          unless link.empty?
            puts "Huh. Already have something in it for id #{med_id}" if new_set[med_id]
            new_set[med_id] = link
          end
        end
      end

      def get_normalized_term(nokonode)
        raise "Override in subclass"
      end

      def get_terms(nokonode)
        raise "Override in subclass"
      end

      def self.from_xml(xml)
        from_nokonode(Nokogiri::XML(xml))
      end

      def self.from_xml_file(filename)
        xml = File.read(filename).encode("UTF-8", "ISO-8859-1")
        from_xml(xml)
      end
    end

    class OEDLinkSet < ExternalDictionaryLinkSet
      def get_terms(nokonode)
        nokonode.xpath("oedHed").map(&:text)
      end

      def get_normalized_term(nokonode)
        norm_node = nokonode.at("norm")
        norm_node&.text
      end
    end

    class DOELinkSet < ExternalDictionaryLinkSet
      def get_terms(nokonode)
        nokonode.xpath("doeHed").map(&:text)
      end

      def get_normalized_term(nokonode)
        get_terms(nokonode).last
      end
    end
  end
end
