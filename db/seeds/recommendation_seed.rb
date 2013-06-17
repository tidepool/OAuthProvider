require 'csv'

class RecommendationSeed
  include SeedsHelper

  def create_seed
    reco = Recommendation.first
    reco_path = File.expand_path('../data/recommendations.csv', __FILE__)

    modified = check_if_inputs_modified(reco, reco_path)
    if modified
      # CSV Order of columns:
      # Personality,Type of Recommendation,Sentence Summary,Title,Link
      whitelist = {'low_extraversion' => 'low_extraversion',
        'high_extraversion' => 'high_extraversion',
        'low_conscientiousness' => 'low_conscientiousness',
        'high_conscientiousness' => 'high_conscientiousness',
        'low_openness' => 'low_openness',
        'high_openness' => 'high_openness',
        'low_neuroticism' => 'low_neuroticism',
        'high_neuroticism' => 'high_neuroticism',
        'low_agreeableness' => 'low_agreeableness',
        'high_agreeableness' => 'high_agreeableness'}

      attributes = [:big5_dimension, :link_type, :display_id, :sentence, :link_title, :link]
      puts 'Creating Recommendations'
      CSV.foreach(reco_path, :encoding => 'windows-1251:utf-8') do |row|
        reco_attr = {}
        row.each_with_index do |value, i|
          reco_attr[attributes[i]] = value
        end
        if whitelist[reco_attr[:big5_dimension]]
          reco_attr[:big5_dimension] = whitelist[reco_attr[:big5_dimension]]
        else
          puts "Wrong dimension: #{reco_attr[:big5_dimension]}"
        end
        reco_attr[:icon_url] = "#{reco_attr[:link_type]}.png"
        reco = Recommendation.where(display_id: reco_attr[:display_id]).first_or_initialize(reco_attr)
        reco.big5_dimension = reco_attr[:big5_dimension] # Ensure the old values with spaces are wiped
        reco.save
        print '.'
      end
    end
    puts
  end
end