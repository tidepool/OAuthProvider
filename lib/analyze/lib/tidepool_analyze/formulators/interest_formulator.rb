require File.expand_path('../../utils/utils.rb', __FILE__)

module TidepoolAnalyze 
  module Formulator
    class InterestFormulator

      def initialize(input_data, formula)        
        @dimension_results = TidepoolAnalyze::Utils::merge_across_stages(input_data)
        @formula = formula
      end

      # Input Data Format
      # [
      #   {
      #     :realistic=>{:word_count=>3, :symbol_count=>1},
      #     :artistic=>{:word_count=>0, :symbol_count=>0},
      #     :social=>{:word_count=>2, :symbol_count=>0},
      #     :enterprising=>{:word_count=>0, :symbol_count=>2},
      #     :investigative=>{:word_count=>1, :symbol_count=>0},
      #     :conventional=>{:word_count=>1, :symbol_count=>0}
      #   }
      # ]
      # Output Data Format
      # {
      #   :realistic => 3,
      #   :artistic => 2,
      #   :social => 1,
      #   :enterprising => 0,
      #   :investigative => 1, 
      #   :conventional => 0
      # }
      def calculate_result
        results = {}
        @dimension_results.each do |dimensions|
          dimensions.each do |dimension, value|
            results[dimension] = value[:word_count] + value[:symbol_count]
          end  
        end
        results
      end
    end
  end
end