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
        # @elements_across_stages = add_up_elements_from_stages(input_data)
        @elements_per_stage = input_data
        @elements = formula
      end

      def calculate_result
        results = []
        @elements_per_stage.each do |element_set|
          results << calculate_result_per_stage(element_set)
        end

        final_result = {}
        results.each do |result|
          result.each do |dimension, value|
            weighted_total = final_result[dimension] ? final_result[dimension][:weighted_total] + value[:weighted_total] : value[:weighted_total]
            count = final_result[dimension] ? final_result[dimension][:count] + value[:count] : value[:count]
            final_result[dimension] = {
              weighted_total: weighted_total,
              count: count
            }
          end
        end
        final_result.each do |dimension, value|
          final_result[dimension][:average] = TidepoolAnalyze::Utils::average(value[:weighted_total], value[:count])
        end
        final_result
      end

      def calculate_result_per_stage(element_set)
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
        element_set.each do |element_name, value|
          # "cf:" is a legacy prefix, if it exists remove it.
          element_name = element_name[3..-1] if element_name[0..2] == 'cf:'
          if @elements[element_name] && @elements[element_name].standard_deviation != 0
            zscore = TidepoolAnalyze::Utils::zscore(value, @elements[element_name].mean, @elements[element_name].standard_deviation)
            # zscore = (value - @elements[element_name].mean) / @elements[element_name].standard_deviation

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
        extraversion_average = TidepoolAnalyze::Utils::average(extraversion, extraversion_count)
        conscientiousness_average = TidepoolAnalyze::Utils::average(conscientiousness, conscientiousness_count)
        neuroticism_average = TidepoolAnalyze::Utils::average(neuroticism, neuroticism_count)
        openness_average = TidepoolAnalyze::Utils::average(openness, openness_count)
        agreeableness_average = TidepoolAnalyze::Utils::average(agreeableness, agreeableness_count)
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