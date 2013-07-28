#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe LayoutHelper do
  describe "#page_title" do
    context "passed blank text" do
      it "returns Lygneo*" do
        page_title.to_s.should == pod_name
      end
    end

    context "passed text" do
      it "returns the text" do
        text = "This is the title"
        page_title(text).should == text
      end
    end
  end
end
