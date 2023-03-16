require "nokogiri"
require "representable/json"
require "middle_english_dictionary/utilities"

##
#
# <link sourceID="MED03366" targetID="14189">
#   <medHed>babanliche, adv.</medHed>
#   <oedHed>baban, n.</oedHed>
#   <oedSub type="derivative">babanly</oedSub>
#   <norm>babanly</norm>
# </link>
##

module MiddleEnglishDictionary
  LinkTarget = Struct.new(:med_id, :target_id, :term)

  class ExternalDictionaryLink
    include Enumerable

    attr_accessor :targets, :normalized_term
    attr_reader :med_id

    def initialize(med_id: nil, normalized_term: nil)
      @med_id = med_id if med_id
      @normalized_term = normalized_term if normalized_term
      @targets = []
    end

    def each
      return enum_for :each unless block_given?
      @targets.each { |x| yield x }
    end

    def med_id=(raw_val)
      raw_val ? MiddleEnglishDictionary.normalize_med_id(raw_val) : nil
    end

    def add_valid_terms!(ids_string:, terms: [])
      ids = ids_string.split("#").map(&:strip)

      return if terms.empty?
      return if ids.empty?

      ids.zip(terms).each do |id, term|
        next if /---/.match?(id)
        @targets << LinkTarget.new(med_id, id, term)
      end

      self
    end

    def empty?
      @targets.empty?
    end
  end

  class LinkTargetRepresenter < Representable::Decorator
    include Representable::JSON
    property :med_id
    property :target_id
    property :term
  end

  class ExternalDictionaryLinkRepresenter < Representable::Decorator
    include Representable::JSON
    property :med_id
    property :normalized_term
    collection :targets, decorator: LinkTargetRepresenter, class: LinkTarget
  end
end
