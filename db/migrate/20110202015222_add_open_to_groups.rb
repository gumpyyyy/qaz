class AddOpenToGroups < ActiveRecord::Migration
  def self.up
    add_column(:groups, :open, :boolean, :default => false)
  end

  def self.down
    remove_column(:groups, :open)
  end
end
