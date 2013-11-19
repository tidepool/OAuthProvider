module TidepoolAnalyze 
  module Formulator
    class EmoIntelligenceFormulator

      def initialize(input_data, formula)
        @emo_results = input_data
      end

      # [
      #   {
      #     primary_multiplier: @primary_multiplier,
      #     secondary_multiplier: @secondary_multiplier,
      #     difficulty_multiplier: @difficulty_multiplier,
      #     time_to_show: @time_to_show,
      #     time_taken: @end_time - @start_time,
      #     emotions: {
      #       correct: [
      #         emotion: entry['value'],
      #         emo_group: entry['emo_group'],
      #         instant_replay: entry['instant_replay'],
      #         type: entry['type']
      #       ], 
      #       incorrect: [
      #         emotion: entry['value'],
      #         emo_group: entry['emo_group'],
      #         instant_replay: entry['instant_replay']
      #       ]
      #     }
      #   },
      #   {

      #   }
      # ]
      CORRECT_SCORE = 100
      INCORRECT_SCORE = -20
      INSTANT_REPLAY_SCORE = -5
      def calculate_result
        results = {}
        score = 0
        corrects = 0
        incorrects = 0
        instant_replays = 0
        time_elapsed = 0
        emo_groups = {
          happy: { corrects: 0, incorrects: 0 },
          sad: { corrects: 0, incorrects: 0 },
          angry: { corrects: 0, incorrects: 0 }, 
          disgust: { corrects: 0, incorrects: 0 }, 
          fear: { corrects: 0, incorrects: 0 },
          surprise: {corrects: 0, incorrects: 0 }
        }

        @emo_results.each do | stage |
          primary_multiplier = stage[:primary_multiplier]
          secondary_multiplier = stage[:secondary_multiplier]
          difficulty_multiplier = stage[:difficulty_multiplier]
          emotions = stage[:emotions]
          stage_score = 0

          corrects += emotions[:correct].length
          incorrects += emotions[:incorrect].length
          emotions[:correct].each do |entry|
            emo_group = entry[:emo_group] ? entry[:emo_group].to_sym : nil
            emo_groups[emo_group][:corrects] += 1 if emo_groups[emo_group]
            multiplier = entry[:type] == 'primary' ? primary_multiplier : secondary_multiplier
            stage_score += CORRECT_SCORE * multiplier + INSTANT_REPLAY_SCORE * entry[:instant_replay]
            instant_replays += entry[:instant_replay]
          end
          emotions[:incorrect].each do |entry|
            emo_group = entry[:emo_group] ? entry[:emo_group].to_sym : nil
            emo_groups[emo_group][:incorrects] += 1 if emo_groups[emo_group]
            stage_score += INCORRECT_SCORE + INSTANT_REPLAY_SCORE * entry[:instant_replay]
            instant_replays += entry[:instant_replay]
          end
          score += (stage_score * difficulty_multiplier)
          time_elapsed += stage[:time_elapsed]
        end
        score = 0 if score < 0
        {
          emo_groups: emo_groups,
          eq_score: score,
          corrects: corrects,
          incorrects: incorrects, 
          instant_replays: instant_replays,
          time_elapsed: time_elapsed
        }
      end
    end
  end
end