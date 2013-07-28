class FollowerRemovePendingAddSharingAndReceiving < ActiveRecord::Migration
  class Follower < ActiveRecord::Base; end

  def self.up
    add_column :followers, :sharing, :boolean, :default => false, :null => false
    add_column :followers, :receiving, :boolean, :default => false, :null => false

    if Follower.count > 0
      execute( <<SQL
        UPDATE followers
          SET followers.sharing = true, followers.receiving = true
            WHERE followers.pending = false
SQL
)

      execute( <<SQL
        DELETE user_preferences.* FROM user_preferences
          WHERE user_preferences.email_type = 'request_acceptance'
            OR user_preferences.email_type = 'request_received'
SQL
)
    end

    remove_foreign_key "followers", "people"
    remove_index :followers, [:person_id, :pending]
    remove_index :followers, [:user_id, :pending]

    add_index :followers, :person_id
    add_foreign_key "followers", "people", :name => "followers_person_id_fk", :dependent => :delete

    remove_column :followers, :pending

    remove_foreign_key :group_pledges, :groups
    add_foreign_key :group_pledges, :groups, :dependent => :delete
  end

  def self.down

    remove_foreign_key "followers", "people"
    remove_index :followers, :person_id

    add_column :followers, :pending, :default => true, :null => false
    add_index :followers, [:user_id, :pending]

    add_index :followers, [:person_id, :pending]
    add_foreign_key "followers", "people", :name => "followers_person_id_fk", :dependent => :delete

    execute( <<SQL
      UPDATE followers
        SET followers.pending = false
          WHERE followers.receiving = true AND followers.sharing = true
SQL
)

    remove_column :followers, :sharing
    remove_column :followers, :receiving

    remove_foreign_key :group_pledges, :groups
    add_foreign_key :group_pledges, :groups
  end
end
