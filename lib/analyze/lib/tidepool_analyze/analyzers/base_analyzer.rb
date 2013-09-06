module TidepoolAnalyze 
  module Analyzer
    class BaseAnalyzer
      def get_time(entry)
        time = 0
        time = entry['time'].to_i if entry['time']  
      end
    end
  end
end
