require 'spec_helper'

describe SpeedAggregateResult do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }
  let(:aggregate_result) { create(:aggregate_result, user: user) }

  before(:each) do 
    @analysis_results = {
      reaction_time2: {
        timezone_offset: Time.zone.now.utc_offset,
        score: {
          :average_time=>529,
          :average_time_simple=>340,
          :average_time_complex=>718,
          :fastest_time=>400,
          :slowest_time=>905,
          :speed_score=>800,
          :version => "2.0"
        },
        final_results: [
          {
            :average_time=>529,
            :average_time_simple=>340,
            :average_time_complex=>718,
            :fastest_time=>400,
            :slowest_time=>905
          }
        ]
      }
    }

    @weekly = []
    (0..6).each do |i|
      @weekly << {
        'speed_score' => 0,
        'average_speed_score' => (i == Time.zone.now.wday ? 500.0 : 0.0),
        'fastest_time' => 1000000,
        'slowest_time' => 0,
        'data_points' => 0
      }
    end
    scores = aggregate_result.scores 
    scores['weekly'] = @weekly
    aggregate_result.scores = scores
    aggregate_result.save!

  end

  it 'updates the trend correctly' do 
    existing_result = SpeedAggregateResult.find(aggregate_result.id)
    time = Time.zone.now
    result = SpeedAggregateResult.create_from_analysis(game, @analysis_results, time, existing_result)

    new_score = @analysis_results[:reaction_time2][:score][:speed_score]
    average_score = @weekly[Time.zone.now.wday]['average_speed_score']
    trend = (new_score.to_f - average_score.to_f) / average_score.to_f
    result.scores['trend'].should == trend
  end

  it 'updates the daily average correctly' do 
    existing_result = SpeedAggregateResult.find(aggregate_result.id)
    existing_result.daily_total = 3000
    existing_result.daily_data_points = 3
    existing_result.daily_average = 1000
    existing_result.save!

    time = Time.zone.now
    result = SpeedAggregateResult.create_from_analysis(game, @analysis_results, time, existing_result)
    result.daily_average.should == (3000 + @analysis_results[:reaction_time2][:score][:speed_score]) / 4
    result.daily_total.should ==  3000 + @analysis_results[:reaction_time2][:score][:speed_score]   
    result.daily_data_points.should == 4
  end

  it 'resets the daily average when the day passes' do 
    existing_result = SpeedAggregateResult.find(aggregate_result.id)
    existing_result.daily_total = 3000
    existing_result.daily_data_points = 3
    existing_result.daily_average = 1000
    existing_result.save!

    time = Time.zone.now + 1.day
    result = SpeedAggregateResult.create_from_analysis(game, @analysis_results, time, existing_result)
    result.daily_average.should == @analysis_results[:reaction_time2][:score][:speed_score]
    result.daily_total.should ==  @analysis_results[:reaction_time2][:score][:speed_score]   
    result.daily_data_points.should == 1
    result.high_scores.should_not be_nil
  end
end