class AddCommunitySpotlightInStream < ActiveRecord::Migration
  def self.up
    add_column :users, :show_popular_in_stream, :boolean, :null => false, :default => true

    ActiveRecord::Base.connection.execute <<SQL
      UPDATE users
        SET show_popular_in_stream = false
SQL
  end

  def self.down
    remove_column :users , :show_popular_in_stream
  end
end
