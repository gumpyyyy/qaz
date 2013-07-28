require 'spec_helper'

describe UserPresenter do
  before do
    @presenter = UserPresenter.new(bob, [])
  end

  describe '#to_json' do
    it 'works' do
      @presenter.to_json.should be_present
    end
  end

  describe '#groups' do
    it 'provides an array of the jsonified groups' do
      group = bob.groups.first
      @presenter.groups.first[:id].should == group.id
      @presenter.groups.first[:name].should == group.name
    end
  end

  describe '#services' do
    it 'provides an array of jsonifed services' do
      fakebook = stub(:provider => 'fakebook')
      bob.stub(:services).and_return([fakebook])
      @presenter.services.should include(:provider => 'fakebook')
    end
  end

  describe '#configured_services' do
    it 'displays a list of the users configured services' do
      fakebook = stub(:provider => 'fakebook')
      bob.stub(:services).and_return([fakebook])
      @presenter.configured_services.should include("fakebook")
    end
  end
end
