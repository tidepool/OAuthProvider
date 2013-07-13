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
  # If they played 
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
    game_types = ['EmoResult', 'ReactionTimeResult']

    selected_game = nil
    selected_time_since_play = 0
    game_types.each do |game_type| 
      recent_result = Result.where('user_id = ? and type = ?', @user.id, game_type).order(:time_played).first
      if recent_result
        last_played = recent_result.time_played 
        time_now = Time.zone.now
        time_since_play = time_now - last_played
        if time_since_play > LAST_PLAY_HOURS && time_since_play > selected_time_since_play
          selected_time_since_play = time_since_play
          selected_game = game_type
        end
      else
        # They never played the game
        selected_game = game_type
      end
    end

    if selected_game
      build_game_recommendation(selected_game)
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
    reco.title = "LET'S GET PERSONAL-IZED"
    reco.link_type = 'Preferences'
    reco.link = "#preferences-training"
    reco.sentence = 'Set up your preferences and TidePool will guide you daily.'

    @recommendations << reco
  end

  def build_game_recommendation(game_def_id)
    game_map = {
      "ReactionTimeResult" => {
        title: "THE REACTION TIME GAME",
        link: "#game/reaction_time",
        link_type: "ReactionTime",
        sentence: "Measure your efficiency throughout the day."
      },
      "EmoResult" => {
        title: "THE EMOTIONS GAME",
        link: "#game/emotions",
        link_type: "Emotions",
        sentence: "Track your daily emotions and watch how they impact your life."        
      }
    }

    reco = Hashie::Mash.new
    reco.title = game_map[game_def_id][:title]
    reco.link_type = game_map[game_def_id][:link_type]
    reco.link = game_map[game_def_id][:link]
    reco.sentence = game_map[game_def_id][:sentence]
   
    @recommendations << reco
  end
end
