require 'nokogiri'
require 'representable/json'

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
  class OEDLink

    OEDSub = Struct.new(:type, :entry)

    attr_accessor :med_id, :oed_id, :med_head,
                  :oed_head, :oed_sub_type, :oed_sub_text, :norm

    def self.new(&blk)
      inst = allocate
      if block_given?
        inst.instance_eval(&blk)
      end
      inst
    end

    def self.new_from_nokonode(nokonode)
      self.new do
        @med_id   = nokonode.attr('sourceID')
        @oed_id   = nokonode.attr('targetID')
        @med_head = nokonode.xpath('medHed').map(&:text).first
        @oed_head = nokonode.xpath('oedHed').map(&:text).first

        if sub = nokonode.at('oedSub')
          @oed_sub_type = sub.attr('type')
          @oed_sub_text = sub.text
        end
        @norm = nokonode.xpath('norm').map(&:text).first
      end
    rescue => e
      require 'pry'; binding.pry
    end


    def linked?
      /\A\d+\Z/.match? oed_id
    end
  end

  class OEDLinkRepresenter < Representable::Decorator
    include Representable::JSON

    property :med_id
    property :oed_id
    property :med_head
    property :oed_head
    property :oed_sub_type
    property :oed_sub_text
    property :norm
  end
end
