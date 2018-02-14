require 'middle_english_dictionary/oed_link'
MEDO = MiddleEnglishDictionary::OEDLink

RSpec.describe MiddleEnglishDictionary::Entry do

    let(:links) { Nokogiri::XML(File.read(SPEC_DATA + 'oed_links.xml')).xpath('/links/link') }

    it "constructs a link" do
      link = MEDO.new_from_nokonode(links.first)
      expect(link.norm).to eq('B')
    end

    it "notices a lack of linking data" do
      link1 = MEDO.new_from_nokonode(links.first)
      link2 = MEDO.new_from_nokonode(links[2])
      expect(link1.linked?).to be(true)
      expect(link2.linked?).to be(false)
    end

    it "gets the norms" do
      norms = links.take(4).map{|x| MEDO.new_from_nokonode(x)}.map(&:norm)
      expect(norms).to match_array(%w[B ba baba babanly])
    end

end

