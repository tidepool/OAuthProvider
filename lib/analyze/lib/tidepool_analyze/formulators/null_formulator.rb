module TidepoolAnalyze 
  module Formulator
    # This is a class that is used in a recipe, where we don't want to
    # formulate a result but just record what is coming from the analysis part.
    class NullFormulator
      def initialize(input_data, formula)
      end

      def calculate_result
        {}
      end
    end
  end
end

