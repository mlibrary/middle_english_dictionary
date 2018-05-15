require 'nokogiri'

# AUTHOR           0    1
# COMMENT          0    1
# E-EDITION        0    9 (children are ED and LINK)
# INDEX            0   57
# INDEXB           0   57
# INDEXC           0    1
# IPMEP            0    3
# JOLLIFFE         0    2
# MSLIST           1    1
# NOTE             0    3 (may contain a STENCIL)
# SEVERS           0   31
# STENCILLIST      1    1
#   -- msgroups
#   -- vargroups
# TITLE            1    1
# WELLS            0    3


module MiddleEnglishDictionary
  class Bib

    # Exactly one
    attr_accessor :title_xml # internal tags
    attr_accessor :title_text

    # 0 or 1
    attr_accessor :author

    # Any number.
    attr_accessor :comment, # might have internal tags
                  :eedition, # Tag is E-EDITION; internal structure
                  :indexes, :indexbs, :indexcs,
                  :ipmeps,
                  :jolliffes,
                  :notes, # can contain a hyperbib stencil
                  :severs,
                  :wells,
                  :author, # if present in AUTHOR tags
                  :author_sort # either SORT on <AUTHOR> or just the AUTHOR

    # An MSLIST only contains MS (manuscript) tags, so well just store them
    attr_accessor :manuscripts

    # A StencilList only contains MSGROUPs, and VARGROUPs so just store them
    attr_accessor :msgroups, :vargroups

    # The XML
    attr_accessor :xml


    # Get a new bib entry from a HYPERMED/ENTRY node
    def self.new_from_nokonode(nokonode)

      bib = self.new
      # First, verify that we've got something that looks like an entry
      raise "Node doesn't look like HYPERMED/ENTRY node" unless looks_like_an_entry_node(nokonode)

      # nab the XML? At least for now
      bib.xml = nokonode.to_xml

      # Zero or 1 author
      bib.author = nokonode.xpath('AUTHOR').map(&:text).first


      # Some stuff doesn't have any internal structure, so just grap them

      bib.indexes = nokonode.xpath('INDEX').map(&:text)
      bib.indexbs = nokonode.xpath('INDEXB').map(&:text)
      bib.indexcs = nokonode.xpath('INDEXC').map(&:text)

      bib.ipmeps    = nokonode.xpath('IPMEP').map(&:text)
      bib.jolliffes = nokonode.xpath('JOLLIFFE').map(&:text)
      bib.severs    = nokonode.xpath('SEVERS').map(&:text)
      bib.wells     = nokonode.xpath('WELLS').map(&:text)

      # Hang onto the title xml, since it can have internal tags
      bib.title_xml = nokonode.at('TITLE').inner_html # really  inner_xml in this case
      bib.title_text = nokonode.at('TITLE').text

      # Author
      authornode = nokonode.xpath('AUTHOR').first
      if authornode
        bib.author = authornode.text
        bib.author_sort = authornode.attr('SORT') || bib.author
      end

      # Manuscripts
      nokonode.xpath('MSLIST/MS').each do |msnode|

      end

      bib

    end


    def self.looks_like_an_entry_node(nokonode)
      nokonode.name == 'ENTRY' and
          ['TITLE', 'STENCILLIST'] - nokonode.children.map(&:name) == []
    end


  end
end
