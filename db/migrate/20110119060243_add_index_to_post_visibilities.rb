class AddIndexToPostVisibilities < ActiveRecord::Migration
  def self.up
    add_index :post_visibilities, [:group_id, :post_id]
  end

  def self.down
    remove_index :post_visibilities, [:group_id, :post_id]
  end
end
