module TidepoolAnalyze
  module Analyzer
    class NullAnalyzer
      include TidepoolAnalyze::Utils::EventValidator

      def initialize(events, formula)
        @events = events
      end

      def calculate_result

        return {}
      end
    end
  end
end