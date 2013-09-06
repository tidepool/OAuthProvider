require File.expand_path('../base_analyzer.rb', __FILE__)

module TidepoolAnalyze
  module Analyzer
    class NullAnalyzer < BaseAnalyzer
      def initialize(events, formula)
        @events = events
      end

      def calculate_result

        return {}
      end
    end
  end
end