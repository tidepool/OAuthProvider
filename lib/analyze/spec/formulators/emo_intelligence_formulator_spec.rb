require 'spec_helper'

module TidepoolAnalyze
  module Formulator

    describe EmoIntelligenceFormulator do 
      before(:all) do
        @input_data = [
          {
           :primary_multiplier => 2,
         :secondary_multiplier => 1,
        :difficulty_multiplier => 1,
                 :time_to_show => 99999,
                 :time_elapsed => 7566,
                     :emotions => {
              :correct => [
                {
                           :emotion => "content",
                           :emo_group => "happy",
                    :instant_replay => 0,
                              :type => "secondary"
                },
                {
                           :emotion => "fear",
                           :emo_group => "fear",
                    :instant_replay => 0,
                              :type => "primary"
                }
            ],
            :incorrect => []
            }
          },
          {
           :primary_multiplier => 2,
         :secondary_multiplier => 1,
        :difficulty_multiplier => 2,
                 :time_to_show => 1000,
                 :time_elapsed => 6999,
                     :emotions => {
              :correct => [
                {
                           :emotion => "embarrassment",
                           :emo_group => "sad",
                    :instant_replay => 0,
                              :type => "primary"
                }
            ],
            :incorrect => [
                {
                           :emotion => "pain",
                           :emo_group => "fear",
                    :instant_replay => 0
                }
              ]
            }
          }
        ]
      end
    
      it 'calculates the emo intelligence' do
        emo_formulator = EmoIntelligenceFormulator.new(@input_data, nil)
        result = emo_formulator.calculate_result
        result.should_not be_nil
        result.should == {
          :emo_groups=>
            {:happy=>{:corrects=>1, :incorrects=>0},
             :sad=>{:corrects=>1, :incorrects=>0},
             :angry=>{:corrects=>0, :incorrects=>0},
             :disgust=>{:corrects=>0, :incorrects=>0},
             :fear=>{:corrects=>1, :incorrects=>1},
             :surprise=>{:corrects=>0, :incorrects=>0}},
           :eq_score=>660,
           :corrects=>3,
           :incorrects=>1,
           :instant_replays=>0,
           :time_elapsed=>14565
         }
      end
    end
  end
end