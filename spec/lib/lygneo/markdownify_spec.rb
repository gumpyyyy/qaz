require 'spec_helper'

describe Lygneo::Markdownify::HTML do
  describe '#autolink' do
    before do
      @html = Lygneo::Markdownify::HTML.new
    end

    it 'should make all of the links open in a new tab' do
      markdownified = @html.autolink("http://joinlygneo.com", nil)
      doc = Nokogiri.parse(markdownified)

      link = doc.css("a")

      link.attr("target").value.should == "_blank"
    end
  end
end