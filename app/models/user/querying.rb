#   Copyright (c) 2010-2011, Lygneo Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

#TODO: THIS FILE SHOULD NOT EXIST, EVIL SQL SHOULD BE ENCAPSULATED IN EvilQueries,
#throwing all of this stuff in user violates demeter like WHOA
module User::Querying
  def find_visible_shareable_by_id(klass, id, opts={} )
    key = (opts.delete(:key) || :id)
    ::EvilQuery::VisibleShareableById.new(self, klass, key, id, opts).post!
  end

  def visible_shareables(klass, opts={})
    opts = prep_opts(klass, opts)
    shareable_ids = visible_shareable_ids(klass, opts)
    klass.where(:id => shareable_ids).select('DISTINCT '+klass.to_s.tableize+'.*').limit(opts[:limit]).order(opts[:order_with_table]).order(klass.table_name+".id DESC")
  end

  def visible_shareable_ids(klass, opts={})
    opts = prep_opts(klass, opts)
    visible_ids_from_sql(klass, opts)
  end

  # @return [Array<Integer>]
  def visible_ids_from_sql(klass, opts={})
    opts = prep_opts(klass, opts)
    opts[:klass] = klass
    opts[:by_members_of] ||= self.group_ids

    post_ids = klass.connection.select_values(visible_shareable_sql(klass, opts)).map { |id| id.to_i }
    post_ids += klass.connection.select_values("#{construct_public_followings_sql(opts).to_sql} LIMIT #{opts[:limit]}").map {|id| id.to_i }
  end

  def visible_shareable_sql(klass, opts={})
    table = klass.table_name
    opts = prep_opts(klass, opts)
    opts[:klass] = klass

    shareable_from_others = construct_shareable_from_others_query(opts)
    shareable_from_self = construct_shareable_from_self_query(opts)

    "(#{shareable_from_others.to_sql} LIMIT #{opts[:limit]}) UNION ALL (#{shareable_from_self.to_sql} LIMIT #{opts[:limit]}) ORDER BY #{opts[:order]} LIMIT #{opts[:limit]}"
  end

  def ugly_select_clause(query, opts)
    klass = opts[:klass]
    select_clause ='DISTINCT %s.id, %s.updated_at AS updated_at, %s.created_at AS created_at' % [klass.table_name, klass.table_name, klass.table_name]
    query.select(select_clause).order(opts[:order_with_table]).where(klass.arel_table[opts[:order_field]].lt(opts[:max_time]))
  end

  def construct_shareable_from_others_query(opts)
    conditions = {
        :pending => false,
        :share_visibilities => {:hidden => opts[:hidden]},
        :followers => {:user_id => self.id, :receiving => true}
    }

    conditions[:type] = opts[:type] if opts.has_key?(:type)

    query = opts[:klass].joins(:followers).where(conditions)

    if opts[:by_members_of]
      query = query.joins(:followers => :group_pledges).where(
        :group_pledges => {:group_id => opts[:by_members_of]})
    end

    ugly_select_clause(query, opts)
  end

  def construct_public_followings_sql(opts)
    groups = Group.where(:id => opts[:by_members_of])
    person_ids = Person.connection.select_values(people_in_groups(groups).select("people.id").to_sql)

    query = opts[:klass].where(:author_id => person_ids, :public => true, :pending => false)

    unless(opts[:klass] == Photo)
      query = query.where(:type => opts[:type])
    end

    ugly_select_clause(query, opts)
  end

  def construct_shareable_from_self_query(opts)
    conditions = {:pending => false }
    conditions[:type] = opts[:type] if opts.has_key?(:type)
    query = self.person.send(opts[:klass].to_s.tableize).where(conditions)

    if opts[:by_members_of]
      query = query.joins(:group_visibilities).where(:group_visibilities => {:group_id => opts[:by_members_of]})
    end

    ugly_select_clause(query, opts)
  end

  def follower_for(person)
    return nil unless person
    follower_for_person_id(person.id)
  end

  def groups_with_shareable(base_class_name_or_class, shareable_id)
    base_class_name = base_class_name_or_class
    base_class_name = base_class_name_or_class.base_class.to_s if base_class_name_or_class.is_a?(Class)
    self.groups.joins(:group_visibilities).where(:group_visibilities => {:shareable_id => shareable_id, :shareable_type => base_class_name})
  end

  def follower_for_person_id(person_id)
    Follower.where(:user_id => self.id, :person_id => person_id).includes(:person => :profile).first
  end

  # @param [Person] person
  # @return [Boolean] whether person is a follower of this user
  def has_follower_for?(person)
    Follower.exists?(:user_id => self.id, :person_id => person.id)
  end

  def people_in_groups(requested_groups, opts={})
    allowed_groups = self.groups & requested_groups
    group_ids = allowed_groups.map(&:id)

    people = Person.in_groups(group_ids)

    if opts[:type] == 'remote'
      people = people.where(:owner_id => nil)
    elsif opts[:type] == 'local'
      people = people.where('people.owner_id IS NOT NULL')
    end
    people
  end

  def groups_with_person person
    follower_for(person).groups
  end

  def posts_from(person)
    ::EvilQuery::ShareablesFromPerson.new(self, Post, person).make_relation!
  end

  def photos_from(person)
    ::EvilQuery::ShareablesFromPerson.new(self, Photo, person).make_relation!
  end

  protected

  # @return [Hash]
  def prep_opts(klass, opts)
    defaults = {
        :order => 'created_at DESC',
        :limit => 15,
        :hidden => false
    }
    defaults[:type] = Stream::Base::TYPES_OF_POST_IN_STREAM if klass == Post
    opts = defaults.merge(opts)

    opts[:order_field] = opts[:order].split.first.to_sym
    opts[:order_with_table] = klass.table_name + '.' + opts[:order]

    opts[:max_time] = Time.at(opts[:max_time]) if opts[:max_time].is_a?(Integer)
    opts[:max_time] ||= Time.now + 1
    opts
  end
end
