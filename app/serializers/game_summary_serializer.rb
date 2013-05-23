class GameSummarySerializer < ActiveModel::Serializer
  attributes :id, :date_taken, :icon, :title, :completion, :num_of_stages

  def title
    object.definition.name
  end


  def icon
    object.definition.icon
  end

  def num_of_stages
    object.definition.stages.length
  end

  def completion
    stage_completed = object.stage_completed + 1
    completion = stage_completed.to_f / object.definition.stages.length
    "#{completion.round(4)*100}%"
  end
end
