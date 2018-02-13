require 'middle_english_dictionary/entry/sense'

RSpec.describe MiddleEnglishDictionary::Entry::Sense do

  let(:sense_nokonode) {Nokogiri::XML(File.read(SPEC_DATA + "simple_sense.xml")).at('SENSE')}
  let(:sense) { MiddleEnglishDictionary::Entry::Sense.new_from_nokonode(sense_nokonode) }

  it "Gets the sense number" do
    expect(sense.sense_number).to eq(1)
  end

  it "Gets the usages" do
    expect(sense.discipline_usages).to eq(['Law'])
    expect(sense.grammatical_usages).to eq(['ppl.'])
  end
end
