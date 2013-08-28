class SpeedArchetypeResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :calculations, :speed_archetype, 
      :fastest_time, :slowest_time, :average_time, :speed_score, :average_time_simple, :average_time_complex, 
      :description, :display_id, :time_played, :time_calculated

  def initialize(object, options={})
    super 
    find_reaction_time_description
  end

  def speed_archetype
    @reaction_time.speed_archetype if @reaction_time
  end

  def description
    @reaction_time.description if @reaction_time
  end

  def display_id
    @reaction_time.display_id if @reaction_time
  end

  def find_reaction_time_description
    desc_id = object.reaction_time_description_id
    if desc_id && desc_id > 12
      # This is only to account for older results, since we changed the descriptions since
      desc_id = 10
    end
    @reaction_time ||= ReactionTimeDescription.find(desc_id) if desc_id
  end
end