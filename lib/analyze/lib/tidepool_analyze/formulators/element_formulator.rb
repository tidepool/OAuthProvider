module TidepoolAnalyze 
  module Formulator
    class ElementFormulator
      # Input Data Format:
      # [
      #   {
      #     "animal" => 10,
      #     "sunset" => 6
      #      ...
      #    },
      #   {
      #     "animal" => 5,
      #     ...
      #   }
      # ]
      # Output Data Format:
      # {
      #   extraversion: { weighted_total: extraversion,
      #                   count: extraversion_count,
      #                   average: extraversion_average },
      #   conscientiousness: {  weighted_total: conscientiousness,
      #                         count: conscientiousness_count,
      #                         average: conscientiousness_average },
      #   neuroticism: { weighted_total: neuroticism,
      #                  count: neuroticism_count,
      #                  average: neuroticism_average },
      #   openness: { weighted_total: openness,
      #               count: openness_count,
      #               average: openness_average },
      #   agreeableness: { weighted_total: agreeableness,
      #                    count: agreeableness_count,
      #                    average: agreeableness_average }
      # }      
      def initialize(input_data, formula)
        @elements_across_stages = add_up_elements_from_stages(input_data)
        @elements = formula
      end

      def add_up_elements_from_stages(input_data)
        merged_results = {}
        input_data.each do |entry|
          entry.each do |element, value|
            if merged_results[element]
              merged_results[element] += value
            else
              merged_results[element] = value
            end
          end
        end
        merged_results
      end

      def calculate_result
        extraversion = 0.0
        conscientiousness = 0.0
        neuroticism = 0.0
        openness = 0.0
        agreeableness = 0.0

        extraversion_count = 0
        conscientiousness_count = 0
        neuroticism_count = 0
        openness_count = 0
        agreeableness_count = 0
        @elements_across_stages.each do |element_name, value|
          # "cf:" is a legacy prefix, if it exists remove it.
          element_name = element_name[3..-1] if element_name[0..2] == 'cf:'
          if @elements[element_name] && @elements[element_name].standard_deviation != 0
            zscore = (value - @elements[element_name].mean) / @elements[element_name].standard_deviation

            extraversion += @elements[element_name].weight_extraversion * zscore
            extraversion_count += 1 if @elements[element_name].weight_extraversion != 0
            conscientiousness += @elements[element_name].weight_conscientiousness * zscore
            conscientiousness_count += 1 if @elements[element_name].weight_conscientiousness != 0
            neuroticism += @elements[element_name].weight_neuroticism * zscore
            neuroticism_count += 1 if @elements[element_name].weight_neuroticism != 0
            openness += @elements[element_name].weight_openness * zscore
            openness_count += 1 if @elements[element_name].weight_openness != 0
            agreeableness += @elements[element_name].weight_agreeableness * zscore
            agreeableness_count += 1 if @elements[element_name].weight_agreeableness != 0
          end
        end
        extraversion_average = (extraversion_count == 0) ? 0 : extraversion/extraversion_count
        conscientiousness_average = (conscientiousness_count == 0) ? 0 : conscientiousness/conscientiousness_count
        neuroticism_average = (neuroticism_count == 0) ? 0 : neuroticism/neuroticism_count
        openness_average = (openness_count == 0) ? 0 : openness/openness_count
        agreeableness_average = (agreeableness_count == 0) ? 0 : agreeableness/agreeableness_count
        {
          extraversion: { weighted_total: extraversion,
                          count: extraversion_count,
                          average: extraversion_average },
          conscientiousness: {  weighted_total: conscientiousness,
                                count: conscientiousness_count,
                                average: conscientiousness_average },
          neuroticism: { weighted_total: neuroticism,
                         count: neuroticism_count,
                         average: neuroticism_average },
          openness: { weighted_total: openness,
                      count: openness_count,
                      average: openness_average },
          agreeableness: { weighted_total: agreeableness,
                           count: agreeableness_count,
                           average: agreeableness_average }
        }
      end
    end
  end
end