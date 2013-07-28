class GroupPresenter < BasePresenter
  def initialize(group)
    @group = group
  end

  def as_json
    { :id => @group.id,
      :name => @group.name,
    }
  end

  def to_json(options = {})
    as_json.to_json(options)
  end
end