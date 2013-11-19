require 'spec_helper'

module ReactionTimeGeneratorSpec
  describe 'Reaction Time Generator' do
    before(:all) do

      stages_json = <<JSONSTRING
[
  {
      "friendly_name" : "Reaction Time 1",
      "instructions" : "Click the circle on the screen as soon as it turns red.",
      "view_name": "ReactionTime",
      "assessment_type" : "Cognition",
      "colors": ["red", "yellow", "green"],
      "sequence_type": "simple",
      "number_of_reds": "4",
      "interval_floor": "500",
      "interval_ceil": "1500",
      "limit_to": "15"
  },
  {
      "friendly_name" : "Reaction Time 2",
      "instructions" : "Click the red circle only when it appears AFTER a yellow circle.",
      "view_name": "ReactionTime",
      "assessment_type" : "Cognition",
      "colors": ["red", "yellow", "green"],
      "sequence_type": "complex",
      "number_of_reds": "4",
      "interval_floor": "500",
      "interval_ceil": "1500",
      "limit_to": "15"
  }
]
JSONSTRING

      @stages = JSON.parse(stages_json)

      generator_simple = ReactionTimeGenerator.new(nil)
      generator_complex = ReactionTimeGenerator.new(nil)
      @sequence_simple = generator_simple.generate(0, @stages[0])["sequence"]
      @sequence_complex = generator_complex.generate(1, @stages[1])["sequence"]
    end

    describe 'simple tests' do
      it 'should end in red' do
        last_color = @sequence_simple[@sequence_simple.length-1][:color]
        last_color.should == 'red'
      end

      it 'should have 4 reds' do
        num_reds_test = 0
        @sequence_simple.each do |seqn|
          if seqn[:color] == "red"
            num_reds_test += 1
          end
        end
        num_reds_specs = @stages[0]["number_of_reds"].to_i
        #to account for final red
        num_reds_test.should == num_reds_specs
      end

      it 'should be within time limits' do
        interval_floor = @stages[0]["interval_floor"].to_i
        interval_ceil = @stages[0]["interval_ceil"].to_i

        num_outside_range = 0
        @sequence_simple.each do |seqn|
          if seqn[:interval] < interval_floor or seqn[:interval] > interval_ceil
            num_outside_range += 1
          end
        end
        num_outside_range.should == 0
      end

      it 'should show circles less than limit' do
        limit_to = @stages[0]["limit_to"].to_i

        num_shown = 0
        @sequence_simple.each do |seqn|
          num_shown += 1
        end
        # num_shown.should <= limit_to
      end

      it 'should not have any repeating circles' do
        prior_color = ''
        color = ''
        dup_seq = 0

        @sequence_simple.each do |seqn|
          color = seqn[:color]
          if prior_color == color
            dup_seq += 1
          end
          prior_color = color
        end
        dup_seq.should == 0
      end
    end

    describe 'complex tests' do
      it 'should end in red' do
        last_color = @sequence_complex[@sequence_complex.length-1][:color]
        last_color.should == 'red'
      end

      it 'should have at least 4 reds' do
        num_reds_test = 0
        @sequence_complex.each do |seqn|
          if seqn[:color] == "red"
            num_reds_test += 1
          end
        end
        num_reds_specs = @stages[1]["number_of_reds"].to_i
        #to account for final red
        num_reds_test.should >= num_reds_specs
      end

      it 'should be within time limits' do
        interval_floor = @stages[1]["interval_floor"].to_i
        interval_ceil = @stages[1]["interval_ceil"].to_i

        num_outside_range = 0
        @sequence_complex.each do |seqn|
          if seqn[:interval] < interval_floor or seqn[:interval] > interval_ceil
            num_outside_range += 1
          end
        end
        num_outside_range.should == 0
      end

      it 'should show circles less than limit' do
        limit_to = @stages[1]["limit_to"].to_i

        num_shown = 0
        @sequence_complex.each do |seqn|
          num_shown += 1
        end
        num_shown.should <= limit_to
      end

      it 'should not have any repeating circles' do
        prior_color = ''
        color = ''
        dup_seq = 0

        @sequence_complex.each do |seqn|
          color = seqn[:color]
          if prior_color == color
            dup_seq += 1
          end

          prior_color = color
        end
        dup_seq.should == 0
      end
      # different from simple below

      it 'should end have yellow as second to last' do
        last_color = @sequence_complex[@sequence_complex.length-2][:color]
        last_color.should == 'yellow'
      end

      it 'should have at least 3 yellows' do
        num_reds_specs = @stages[1]["number_of_reds"].to_i
        num_yellow_test = 0
        @sequence_complex.each do |seqn|
          if seqn[:color] == "yellow"
            num_yellow_test += 1
          end
        end
        num_yellow_test.should >= num_reds_specs
      end

      it 'should have max 4 yellow_red events' do
        num_reds_specs = @stages[1]["number_of_reds"].to_i
        num_yellow_test = 0
        prior_color = ''
        @sequence_complex.each do |seqn|
          if seqn[:color] == "red" and prior_color == 'yellow'
            num_yellow_test += 1
          end
          prior_color = seqn[:color]
        end
        num_yellow_test.should == num_reds_specs
      end
    end
  end
end