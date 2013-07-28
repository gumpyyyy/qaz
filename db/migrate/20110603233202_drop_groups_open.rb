class DropGroupsOpen < ActiveRecord::Migration
  require Rails.root.join("db", "migrate", "20110202015222_add_open_to_groups")
  def self.up
    AddOpenToGroups.down
  end

  def self.down
    AddOpenToGroups.up
  end
end
