require 'spec_helper'

module TidepoolAnalyze
  module ScoreGenerator

    describe ReactionTime2Score do
      before(:all) do
        @input_data = [
          {
            :average_time=>529,
            :average_time_simple=>340,
            :average_time_complex=>718,
            :fastest_time=>400,
            :slowest_time=>905,
            :score=>400, 
            :stage_data=>[]
          }
        ] 
      end

      it 'should calculate the reaction_time score correctly' do
        reaction_time_score = ReactionTime2Score.new
        result = reaction_time_score.calculate_score(@input_data)

        result.should == {
          :average_time=>529,
          :average_time_simple=>340,
          :average_time_complex=>718,
          :fastest_time=>400,
          :speed_score=>400,
          :slowest_time=>905,
          :stage_data=>[],
          :version => "2.0"
        }
      end
    end
  end
end