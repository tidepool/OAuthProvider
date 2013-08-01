class SocialGameSetup
  def setup_game(name, host_user, calling_ip, game_id)
    if name && !name.empty?
      definition = SocialGameDefinition.where(unique_name: name).first    
      if definition.nil?
        raise ActiveRecord::RecordNotFound, "Game definition was not found."
      end  
    else
      raise ActiveRecord::RecordNotFound, "Game definition was not supplied."
    end

    social_game = SocialGame.create_by_definition(definition, host_user, calling_ip)
    
    host_game_definition = Definition.where(unique_name: definition.host_game_name).first
    if game_id 
      host_game = Game.find(game_id)
    else
      host_game = Game.create_by_definition(host_game_definition, host_user, calling_ip, social_game)
    end

    social_game.host_game_id = host_game.id

    social_game
  end

  # [
  #   {
  #     tidepool_id: '1234',
  #     provider: 'facebook',
  #     provider_id: 'facebook_user_id',
  #     email: 'foo@foo.com'
  #   },
  #   {
  #   }
  # ]  
  def sort_out_participants(participants, social_game_id)
    tidepool_list = []
    external_list = []
    email_list = []

    participants.each do |participant|
      tidepool_list << participant['tidepool_id'] if participant.has_key?('tidepool_id')
      external_list << participant['provider_id'] if participant.has_key?('provider_id')
      email_list << participant['email'] if participant.has_key?('email') && !participant.has_key('tidepool_id')
    end

    tidepool_users = []
    tidepool_users << User.where("id IN (?) OR email IN (?)", tidepool_list, email_list).all
    tidepool_users << Authentication.where(uid: external_list, provider: 'facebook').all
    tidepool_users.flatten!

    participants.each do |participant|
      found_user = check_if_participant_is_tidepool(participant, tidepool_users)
      if found_user
        participant['user_type'] = 'registered'
        participant['tidepool_id'] = found_user.id
      else
        # They will be guest users
        # But will link them with these credentials, when they first visit the end point for 
        # guest user creation

        participant['user_type'] = 'guest'
      end
      participant['social_game_id'] = social_game_id 
    end
    participants
  end

  def game_links(participants)


  end

  def send_game_invitations(participants)
    # Send Email invitation if we have email
    # Send Facebook invitation if Facebook user
    # Send Push Notification if Tidepool user and has the iOS app

  end

  def check_if_participant_is_tidepool(participant, tidepool_users)
    found_user = nil
    tidepool_users.each do |user|
      if ((user.class == Authentication && user.uid == participant['uid']) || 
        (user.class == User && (user.id == participant['tidepool_id'] || user.email == participant['email'])))
        found_user = user
        break
      end
    end
    found_user
  end

end