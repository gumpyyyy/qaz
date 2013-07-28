class AddOrderIdToGroups < ActiveRecord::Migration
  def self.up
    add_column :groups, :order_id, :integer
  end

  def self.down
    remove_column :groups, :order_id
  end
end
