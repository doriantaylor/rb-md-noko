RSpec.describe MD::Noko do
  it "has a version number" do
    expect(MD::Noko::VERSION).not_to be nil
  end

  md = nil

  it 'initializes ok' do
    md = MD::Noko.new
    expect(md).to be_a(MD::Noko)
  end

  it 'turns markdown source into Nokogiri XML' do
    src = <<-DANKWORM
# HURR

lol preamble

## DURR

important

![figure](dot.jpeg)
    DANKWORM

    doc = md.ingest src, 'http://some.website/foo'
    expect(doc).to be_a(Nokogiri::XML::Document)

    #warn doc.to_xml
  end
end
