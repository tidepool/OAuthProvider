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

      attributes = [:big5_dimension, :link_type, :sentence, :link_title, :link]
      puts 'Creating Recommendations'

      # TODO: This is very inefficient for a large number of records
      # For now we are creating these by seeding, but we should have a 
      # better way of loading in recommendation in batch.
      Recommendation.destroy_all

      CSV.foreach(reco_path, :encoding => 'windows-1251:utf-8') do |row|
        reco_attr = {}
        row.each_with_index do |value, i|
          reco_attr[attributes[i]] = value
        end

        reco_attr[:icon_url] = "#{reco_attr[:link_type]}.png"
        reco = Recommendation.create(reco_attr)
        print '.'
      end
    end
    puts
  end
end