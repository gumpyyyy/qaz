class AddFollowersVisible < ActiveRecord::Migration
  def self.up
    add_column :groups, :followers_visible, :boolean, :default => true, :null => false
    add_index :groups, [:user_id, :followers_visible]

    ActiveRecord::Base.connection.execute <<-SQL
    UPDATE groups
      SET followers_visible = false
      WHERE followers_visible IS NULL
    SQL
  end

  def self.down
    remove_index :groups, [:user_id, :followers_visible]
    remove_column :groups, :followers_visible
  end
end
