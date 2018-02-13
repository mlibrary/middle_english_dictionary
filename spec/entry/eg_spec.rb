require 'middle_english_dictionary/entry'

RSpec.describe MiddleEnglishDictionary::Entry::EG do

  let(:e) {MiddleEnglishDictionary::Entry.new_from_xml_file(SPEC_DATA + 'well_rounded.xml')}

  it "gets the right subdef letters" do
    expect(e.senses.first.egs.map(&:subdef_entry)).to match_array(%w(a b))
  end

  it "Gets empty string when there is no subdef letter" do
    expect(e.senses[1].egs.first.subdef_entry).to eq("")
  end

end
