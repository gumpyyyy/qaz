require 'spec_helper'

describe WebfingerProfile do
  let(:webfinger_profile){File.open(Rails.root.join("spec", "fixtures", "finger_xrd")).read.strip}
  let(:not_lygneo_webfinger){File.open(Rails.root.join("spec", "fixtures", "nonseed_finger_xrd")).read.strip}

  let(:account){"tom@tom.joinlygneo.com"}
  let(:profile){ WebfingerProfile.new(account, webfinger_profile) }
  
  context "parsing a lygneo profile" do
    
    describe '#valid_lygneo_profile?' do
      it 'should check all of the required fields' do
        manual_nil_check(profile).should == profile.valid_lygneo_profile?
      end
    end

    describe '#set_fields' do
      it 'should check to make sure it has a the right webfinger profile' do
        proc{ WebfingerProfile.new("nottom@tom.joinlygneo.com", webfinger_profile)}.should raise_error 
      end

      it 'should handle a non-lygneo profile without blowing up' do
        proc{ WebfingerProfile.new("evan@status.net", not_lygneo_webfinger)}.should_not raise_error 
      end
      
      [:links, :hcard, :guid, :seed_location, :public_key].each do |field|
        it 'should sets the #{field} field' do
          profile.send(field).should be_present
        end
      end
    end
  end

    def manual_nil_check(profile)
      profile.instance_variables.each do |var|
        var = var.to_s.gsub('@', '')
        return false if profile.send(var).nil? == true
      end
      true
    end
end
