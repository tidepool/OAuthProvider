require 'csv'

module TidepoolAnalyze
  module SheetLoaders
    class CirclesSheetLoader
      def load(filename)
        attributes = [
          :name_pair, 
          :size_weight,
          :size_sd, 
          :size_mean, 
          :distance_weight, 
          :distance_sd, 
          :distance_mean, 
          :overlap_weight, 
          :overlap_sd, 
          :overlap_mean, 
          :maps_to
        ]
        CSV.foreach(circle_path) do |row|

        end
      end
    end

  end
end
