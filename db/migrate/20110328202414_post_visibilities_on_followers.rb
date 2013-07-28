class PostVisibilitiesOnFollowers < ActiveRecord::Migration
  class PostVisibility < ActiveRecord::Base; end
  def self.move_author_pvs_to_group_pvs
    where_clause = <<SQL
      FROM post_visibilities as pv
        INNER JOIN groups ON groups.id = pv.group_id
        INNER JOIN posts ON posts.id = pv.post_id
          INNER JOIN people ON posts.author_id = people.id
      WHERE people.owner_id = groups.user_id
SQL

    execute("INSERT into group_visibilities SELECT pv.id, pv.post_id, pv.group_id, pv.created_at, pv.updated_at #{where_clause}")

    execute("DELETE pv #{where_clause}")
  end

  def self.set_pv_follower_ids
    execute <<SQL
    UPDATE post_visibilities as pv
      INNER JOIN posts ON posts.id = pv.post_id
        INNER JOIN people ON posts.author_id = people.id
      INNER JOIN groups ON groups.id = pv.group_id
        INNER JOIN users ON users.id = groups.user_id
          INNER JOIN followers ON followers.user_id = users.id
    SET pv.follower_id = followers.id
    WHERE people.id = followers.person_id
SQL
  end

  def self.delete_duplicate_pvs
    execute('DELETE FROM post_visibilities WHERE post_visibilities.follower_id = 0')

    duplicate_rows = execute <<SQL
      SELECT COUNT(pv.follower_id), pv.follower_id, pv.post_id from post_visibilities AS pv
        GROUP BY pv.follower_id, pv.post_id
          HAVING COUNT(*)>1;
SQL
    duplicate_rows.each do |row|
      count = row.first
      follower_id = row[1]
      post_id = row.last

      execute <<SQL
        DELETE FROM post_visibilities
        WHERE post_visibilities.follower_id = #{follower_id} AND post_visibilities.post_id = #{post_id}
        LIMIT #{count-1}
SQL
    end
  end

  def self.delete_disconnected_pvs
    execute <<SQL
    DELETE post_visibilities FROM post_visibilities
      LEFT OUTER JOIN posts ON post_visibilities.post_id = posts.id
      LEFT OUTER JOIN groups ON post_visibilities.group_id = groups.id
    WHERE groups.id IS NULL OR posts.id IS NULL
SQL
  end

  def self.pv_count
    @pv_count ||= PostVisibility.count
  end

  def self.up
    create_table :group_visibilities do |t|
      t.integer :post_id, :null => false
      t.integer :group_id, :null => false
      t.timestamps
    end
    add_index :group_visibilities, [:post_id, :group_id], :unique => true
    add_index :group_visibilities, [:group_id]
    add_index :group_visibilities, [:post_id]
    add_foreign_key :group_visibilities, :groups, :dependent => :delete
    add_foreign_key :group_visibilities, :posts, :dependent => :delete

    delete_disconnected_pvs if pv_count > 0

    add_column :post_visibilities, :follower_id, :integer, :null => false

    move_author_pvs_to_group_pvs if pv_count > 0
    set_pv_follower_ids if pv_count > 0

    delete_duplicate_pvs if pv_count > 0

    remove_index :post_visibilities, [:group_id, :post_id]
    remove_column :post_visibilities, :group_id

    add_index :post_visibilities, [:follower_id, :post_id], :unique => true
    add_index :post_visibilities, [:follower_id]
    add_foreign_key :post_visibilities, :followers, :dependent => :delete
    add_foreign_key :post_visibilities, :posts, :dependent => :delete
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
