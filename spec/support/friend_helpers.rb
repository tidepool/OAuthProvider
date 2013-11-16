module FriendHelpers
  def make_friends(user1, user2) 
    friends_service = FriendsService.new
    friends_service.invite_friends(user1.id, [{id: user2.id}])
    friends_service.accept_friends(user2.id, [{id: user1.id}])
  end

  def invite_friends(user1, user2)
    friends_service = FriendsService.new
    friends_service.invite_friends(user1.id, [{id: user2.id}])
  end

  def create_friends(user, users)
    invite_list = users.map { |friend| { id: friend.id} }
    friend_service = FriendsService.new
    friend_service.invite_friends(user.id, invite_list)
    invite_list.each do |friend|
      friend_service.accept_friends(friend[:id], [{ id: user.id }] )
    end
  end
end
