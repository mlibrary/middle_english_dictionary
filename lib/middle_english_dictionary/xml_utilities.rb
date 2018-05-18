require 'nokogiri'

module MiddleEnglishDictionary
  module XMLUtilities


    def self.arities(doc, xpath)
      h = Hash.new {|h, k| h[k] = {}}

      nodes = doc.xpath(xpath)

      kids = nodes.flat_map(&:children).flat_map(&:name).uniq - ['text']

      kids.each do |k|
        nodes.each do |x|
          h[k][x.xpath(k).count] = true
        end
      end

      h.keys.sort.inject({}) do |acc, k|
        arities = h[k].keys
        acc[k]  = [arities.min, arities.max]
        acc
      end

    end

    def self.enclose_run_of_tags!(node:, enclosing_node_string:, tagname:)
      iter = node.children.select{|x| !x.text? or x.text =~ /\S/}.enum_for(:each )
      loop do
        n = iter.next
        if n.name == tagname
          y = n.add_previous_sibling(enclosing_node_string).first
          while n.name == tagname
            n.parent = y
            n = iter.next
          end
        end
      end
    end

    def self.case_raise_all_tags!(node)
      node.traverse {|node| node.name = node.name.upcase if node.class == Nokogiri::XML::Element}
      nil
    end

    # @return [String] pretty-printable XML
    def self.pretty_xml(xml)
      PrettyXSL.apply_to(Nokogiri::XML(xml)).to_s
    end

    PrettyXSLSS = <<-EOXSL
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
  <xsl:param name="indent-increment" select="'   '"/>
  <xsl:template name="newline">
    <xsl:text disable-output-escaping="yes">
</xsl:text>
  </xsl:template>
  <xsl:template match="comment() | processing-instruction()">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:copy />
  </xsl:template>
  <xsl:template match="text()">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <xsl:template match="text()[normalize-space(.)='']"/>
  <xsl:template match="*">
    <xsl:param name="indent" select="''"/>
    <xsl:call-template name="newline"/>
    <xsl:value-of select="$indent"/>
      <xsl:choose>
       <xsl:when test="count(child::*) > 0">
        <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="*|text()">
           <xsl:with-param name="indent" select="concat ($indent, $indent-increment)"/>
         </xsl:apply-templates>
         <xsl:call-template name="newline"/>
         <xsl:value-of select="$indent"/>
        </xsl:copy>
       </xsl:when>
       <xsl:otherwise>
        <xsl:copy-of select="."/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
    EOXSL

    PrettyXSL = Nokogiri::XSLT(PrettyXSLSS)


  end
end
