require 'spec_helper'

describe SnoozerGenerator do
  let (:user1) { create(:user) }
  let (:game) { create(:game, user: user1)}
  let (:results) { create_list(:speed_archetype_rand_scores, 10, user: user1, game: game) }
  let (:results_less) { create_list(:speed_archetype_rand_scores, 3, user: user1, game: game) }
  before :each do 
    definition_json = IO.read(Rails.root.join('db/seeds/data/definitions/snoozer.json'))
    @definition = JSON.parse(definition_json)
  end

  it 'calculates the average of 5 recent games' do
    results
    time_sorted = results.sort { |x, y| y.time_played <=> x.time_played }
    average = 0
    (0..4).each do |i|
      average += time_sorted[i][:score]["speed_score"].to_i
    end
    average /= 5

    generator = SnoozerGenerator.new(user1)
    average_score = generator.calculate_recent_average(user1.id)
    average_score.should == average
  end

  it 'calculates the average even if there are less than 3 games' do 
    results_less
    time_sorted = results_less.sort { |x, y| y.time_played <=> x.time_played }
    average = 0
    (0...time_sorted.length).each do |i|
      average += time_sorted[i][:score]["speed_score"].to_i
    end
    average /= time_sorted.length    

    generator = SnoozerGenerator.new(user1)
    average_score = generator.calculate_recent_average(user1.id)
    average_score.should == average
  end

end