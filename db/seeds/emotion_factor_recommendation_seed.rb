require 'csv'

class EmotionFactorRecommendationSeed
  include SeedsHelper

  def create_seed
    reco = EmotionFactorRecommendation.first
    reco_path = File.expand_path('../data/emotion_factor_recommendations.csv', __FILE__)

    modified = check_if_inputs_modified(reco, reco_path)
    if modified
      # CSV Order of columns:
      # Personality,Type of Recommendation,Sentence Summary,Title,Link
      whitelist = emo_factor_whitelist

      attributes = [:name, :perc1, :perc2, :perc3, :perc4, :perc5]
      puts 'Creating Emotion Factor Recommendations'
      CSV.foreach(reco_path, :encoding => 'windows-1251:utf-8') do |row|
        reco_attr = {}
        row.each_with_index do |value, i|    
          if i > 0 
            reco_attr[:recommendations_per_percentile] ||= []
            reco_attr[:recommendations_per_percentile] << value 
          else
            reco_attr[attributes[i]] = value   
          end
        end
        if whitelist[reco_attr[:name]]
          reco_attr[:name] = whitelist[reco_attr[:name]]
        else
          puts "Wrong dimension: #{reco_attr[:name]}"
          raise Exception.new
        end

        reco = EmotionFactorRecommendation.where(name: reco_attr[:name]).first_or_initialize(reco_attr)
        reco.update_attributes(reco_attr)
        reco.name = reco_attr[:name] # Ensure the old values with spaces are wiped
        reco.save
        print '.'
      end
    end
    puts

  end
end