class AddAutoFollowBackToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auto_follow_back, :boolean, :default => false
    add_column :users, :auto_follow_back_group_id, :integer
  end

  def self.down
    remove_column :users, :auto_follow_back
    remove_column :users, :auto_follow_back_group
  end
end
