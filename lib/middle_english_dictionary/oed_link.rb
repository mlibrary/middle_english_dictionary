require 'nokogiri'

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
                  :oed_head, :oed_sub, :norm

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
        @med_head = nokonode.at('medHed').text
        @oed_head = nokonode.at('oedHed').text
        if sub = nokonode.at('oedSub')
          @oed_sub = OEDSub.new(sub.attr('type'),
                               sub.text)
        end
        @norm = nokonode.at('norm').text
      end
    end

    def linked?
      /\A\d+\Z/.match? oed_id
    end
  end
end
