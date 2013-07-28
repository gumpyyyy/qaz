module ServicesHelper
  @@follower_proxy = Follower.new(:groups => [])
  def follower_proxy(friend)
    friend.follower || @@follower_proxy.dup.tap{|c| c.person = friend.person}
  end
end
