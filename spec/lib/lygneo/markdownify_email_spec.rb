require 'spec_helper'

describe Lygneo::Markdownify::Email do
  describe '#preprocess' do
    before do
      @html = Lygneo::Markdownify::Email.new
    end

    it 'should autolink a hashtag' do
      markdownified = @html.preprocess("#tag")
      markdownified.should == "[#tag](http://localhost:9887/tags/tag)"
    end

    it 'should autolink multiple hashtags' do
      markdownified = @html.preprocess("There are #two #Tags")
      markdownified.should == "There are [#two](http://localhost:9887/tags/two) [#Tags](http://localhost:9887/tags/tags)"
    end

    it 'should not autolink headers' do
      markdownified = @html.preprocess("# header")
      markdownified.should == "# header"
    end
  end

  describe "Markdown rendering" do
    before do
      @markdown = Redcarpet::Markdown.new(Lygneo::Markdownify::Email)
      @sample_text = "# Header\n\n#messages containing #hashtags should render properly"
    end

    it 'should render the message' do
      rendered = @markdown.render(@sample_text).strip
      rendered.should == "<h1>Header</h1>\n\n<p><a href=\"http://localhost:9887/tags/messages\">#messages</a> containing <a href=\"http://localhost:9887/tags/hashtags\">#hashtags</a> should render properly</p>"
    end
  end
end