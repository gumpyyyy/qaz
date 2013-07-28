require 'spec_helper'

describe GroupPresenter do
  before do
    @presenter = GroupPresenter.new(bob.groups.first)
  end

  describe '#to_json' do
    it 'works' do
      @presenter.to_json.should be_present
    end
  end
end