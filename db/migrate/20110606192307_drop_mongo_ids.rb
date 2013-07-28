class DropMongoIds < ActiveRecord::Migration
  def self.up
    remove_column :groups, :mongo_id
    remove_column :groups, :user_mongo_id
    remove_column :comments, :mongo_id
    remove_column :followers, :mongo_id
    remove_column :invitations, :mongo_id
    remove_column :people, :mongo_id
    remove_column :posts, :mongo_id
    remove_column :profiles, :mongo_id
    remove_column :services, :mongo_id
    remove_column :services, :user_mongo_id
    remove_column :users, :mongo_id
  end

  def self.down
    add_column :users, :mongo_id
    add_column :services, :user_mongo_id
    add_column :services, :mongo_id
    add_column :profiles, :mongo_id
    add_column :posts, :mongo_id
    add_column :people, :mongo_id
    add_column :invitations, :mongo_id
    add_column :followers, :mongo_id
    add_column :comments, :mongo_id
    add_column :groups, :user_mongo_id
    add_column :groups, :mongo_id
  end
end
