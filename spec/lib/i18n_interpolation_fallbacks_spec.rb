#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'

describe "i18n interpolation fallbacks" do
  describe "when string does not require interpolation arguments" do
    it "works normally" do
      I18n.t('user.invalid',
             :resource_name => "user",
             :scope => "devise.failure",
             :default => [:invalid, "invalid"]).should == "Invalid username or password."
    end
  end
  describe "when string requires interpolation arguments" do
    context "current locale has no fallbacks" do
      # ago: "%{time} ago" (in en.yml)
      it "returns the translation when all arguments are provided" do
        I18n.t('ago', :time => "2 months").should == "2 months ago"
      end
      it "returns the translation without substitution when all arguments are omitted" do
        I18n.t('ago').should == "%{time} ago"
      end
      it "raises a MissingInterpolationArgument when arguments are wrong" do
        expect { I18n.t('ago', :not_time => "2 months") }.to raise_exception(I18n::MissingInterpolationArgument)
      end
    end
    context "current locale falls back to English" do
      before do
        @old_locale = I18n.locale
        I18n.locale = 'it'
        I18n.backend.store_translations('it', {"nonexistant_key" => "%{random_key} here is some Italian"})
      end
      after do
        I18n.locale = @old_locale
      end
      describe "when all arguments are provided" do
        it "returns the locale's translation" do
          I18n.t('nonexistant_key', :random_key => "Hi Alex,").should == "Hi Alex, here is some Italian"
        end
      end
      describe "when no arguments are provided" do
        it "returns the locale's translation without substitution" do
          I18n.t('nonexistant_key').should == "%{random_key} here is some Italian"
        end
      end
      describe "when arguments are wrong" do
        describe "when the English translation works" do
          it "falls back to English" do
            I18n.backend.store_translations('en', {"nonexistant_key" => "Working English translation"})
            I18n.t('nonexistant_key', :hey => "what").should == "Working English translation"
          end
        end
        describe "when the English translation does not work" do
          it "raises a MissingInterpolationArgument" do
            I18n.backend.store_translations('en', {"nonexistant_key" => "%{random_key} also required, so this will fail"})
            expect { I18n.t('nonexistant_key', :hey => "what") }.to raise_exception(I18n::MissingInterpolationArgument)
          end
        end
      end
    end
  end
end
