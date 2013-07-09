require 'spec_helper'

# module TidepoolAnalyze
#   module Aggregator

#     describe 'Image Rank Aggregator' do
#       before(:all) do
#         elements = YAML::load(IO.read(File.expand_path('../../fixtures/elements.yaml', __FILE__)))
#         new_elements = {}
#         elements.each { |element, value| new_elements[element] = ::OpenStruct.new(value)}

#         raw_results = [ { :stage => '0',
#                           :results => { 'animal' => 10, 'adult' => 5, 'alone' => 7, 'abstraction' => 15 }
#                         },
#                         {
#                           :stage => '3',
#                           :results => { 'sunset' => 10, 'adult' => 2, 'male' => 7, 'abstraction' => 6 }
#                         }]

#         @aggregator = ImageRankAggregator.new(raw_results, {})
#         @aggregator.elements = new_elements
#       end

#       it 'should flatten the Image elements across stages into one hash' do
#         results = @aggregator.flatten_stages_to_results

#         results.length.should == 6
#         results['sunset'].should == 10
#         results['adult'].should == 7
#         results['abstraction'].should == 21
#         results['male'].should == 7
#         results['alone'].should == 7
#         results['animal'].should == 10
#       end

#       it 'should calculate the Big 5 dimensions from elements' do
#         result = @aggregator.calculate_result
#         result[:big5].should_not be_nil
#         result[:big5][:extraversion][:weighted_total].should be_within(0.0005).of(0.0)
#         result[:big5][:conscientiousness][:weighted_total].should be_within(0.0005).of(2.2381)
#         result[:big5][:conscientiousness][:average].should be_within(0.0005).of(2.2381)
#         result[:big5][:neuroticism][:weighted_total].should be_within(0.0005).of(-0.5493)
#         result[:big5][:neuroticism][:average].should be_within(0.0005).of(-0.1831)
#         result[:big5][:openness][:weighted_total].should be_within(0.0005).of(0.0)
#         result[:big5][:agreeableness][:weighted_total].should be_within(0.0005).of(-0.9561)
#         result[:big5][:agreeableness][:average].should be_within(0.0005).of(-0.2390)
#       end
#     end
#   end
# end