class GameSummarySerializer < ActiveModel::Serializer
  attributes :id, :name, :date_taken, :completion, :num_of_stages, :user_id

  def num_of_stages
    (object.definition.stages) ? object.definition.stages.length : 0
  end

  def completion
    if object.stage_completed
      stage_completed = object.stage_completed + 1
      if object.definition.stages && object.definition.stages.length > 0
        completion = stage_completed.to_f / object.definition.stages.length
        "#{completion.round(4)*100}%"
      else
        "100%"
      end
    else
      "100%"
    end
  end
end
