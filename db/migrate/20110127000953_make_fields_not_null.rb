class MakeFieldsNotNull < ActiveRecord::Migration
  def self.non_nullable_fields
    fields = {
      :group_pledges => [:group_id, :follower_id],
      :groups => [:user_id, :name],
      :comments => [:text, :post_id, :person_id, :guid],
      :followers => [:user_id, :person_id, :pending],
      :data_points => [:key, :value, :statistic_id],
      :invitations => [:recipient_id, :sender_id],
      :notifications => [:recipient_id, :actor_id, :action, :unread],
      :people => [:guid, :url, :lygneo_handle, :serialized_public_key],
      :post_visibilities => [:group_id, :post_id],
      :posts => [:person_id, :public, :guid, :pending, :type],
      :profiles => [:person_id, :searchable],
      :requests => [:sender_id, :recipient_id],
      :services => [:type, :user_id],
      :statistics => [:time],
      :users => [:getting_started, :invites, :disable_mail]
    }
  end

  def self.up
    remove_index(:profiles, :person_id)
    non_nullable_fields.each_pair do |table, columns|
      columns.each do |column|
        change_column_null(table, column, false)
      end
    end
    add_index :profiles, :person_id
  end

  def self.down
    non_nullable_fields.each_pair do |table, columns|
      columns.each do |column|
        change_column_null(table, column, true)
      end
    end
  end
end
