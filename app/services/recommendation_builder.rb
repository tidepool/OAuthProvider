class RecommendationBuilder
  def initialize(user) 
    @user = user
    @recommendations = []
  end

  LAST_PLAY_HOURS = 5.hours
  # Have they set preferences?
  # Check both:
  #   Have they played reaction_time game? (n hours)
  #   Have they played emotion_time game?
  # If they played have then randomize the recommendations in the reco widget
  def recommendations
    check_preference_setup 
    check_last_played_time
    add_personality_recommendations

    @recommendations
  end

  def check_preference_setup
    if @user.preferences.nil? || @user.preferences.empty?
      build_preferences_recommendation
    end
  end

  def check_last_played_time
    recent_results = Result.where('user_id = ?', @user.id).order(:time_played).limit(5)
    return if recent_results.nil? || recent_results.empty?

    last_played = recent_results[0].time_played 
    time_now = Time.zone.now
    if time_now - last_played > LAST_PLAY_HOURS
      recent_results.each do |result|
        case result.type
        when 'EmoResult'
          build_game_recommendation(:reaction_time)
          break;
        when 'ReactionTimeResult'
          build_game_recommendation(:emotions)
          break;
        end
      end
    end
  end

  def add_personality_recommendations
    personality = @user.personality
    return if personality.nil?
    
    personality_recos = Recommendation.where('big5_dimension = ?', personality.big5_dimension)

    numbers = generate_non_repeating_random(3, 0...5)
    (0..2).each do |n|
      rec_no = numbers[n]      
      if rec_no <= personality_recos.length - 1
        reco = Hashie::Mash.new
        reco.title = personality_recos[rec_no].link_title
        reco.link_type = personality_recos[rec_no].link_type
        reco.link = personality_recos[rec_no].link
        reco.sentence = personality_recos[rec_no].sentence

        @recommendations << reco
      end
    end
  end

  def generate_non_repeating_random(count, working_set)
    selected_nums = {}
    numbers = []
    (1..count).each do |n|
      random_generator = Random.new
      bad_selection = true
      while bad_selection
        random_number = random_generator.rand(working_set)
        unless selected_nums.key?(random_number.to_s)
          selected_nums[random_number.to_s] = random_number
          bad_selection = false
          numbers << random_number
        end
      end
    end
    numbers
  end

  def build_preferences_recommendation
    reco = Hashie::Mash.new
    reco.title = 'Preferences'
    reco.link_type = ''
    reco.link = "#preferences"
    reco.sentence = 'You have not set your preferences, would you like to set them now?'

    @recommendations << reco
  end

  def build_game_recommendation(game_def_id)
    game_name = {
      reaction_time: 'Reaction Time',
      emotions: 'Emotions'
    }

    reco = Hashie::Mash.new
    reco.title = 'Game'
    reco.link_type = 'TidePoolGame'
    reco.link = "#game/#{game_def_id.to_s}"
    reco.sentence = "You have not played any games for a while, would you like to play an #{game_name[game_def_id]} game?"
   
    @recommendations << reco
  end
end
