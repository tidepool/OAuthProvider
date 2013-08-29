class SpeedArchetypeResultSerializer < ActiveModel::Serializer
  attributes :id, :game_id, :user_id, :type, :calculations, :speed_archetype, 
      :fastest_time, :slowest_time, :average_time, :speed_score, :average_time_simple, :average_time_complex, 
      :description, :display_id, :time_played, :time_calculated

  def initialize(object, options={})
    super 
    find_speed_archetype_description
  end

  def speed_score
    output = 0
    output = object.speed_score if object.speed_score
    output
  end

  def speed_archetype
    output = "Progress1"
    output = @reaction_time.speed_archetype if @reaction_time && @reaction_time.speed_archetype
    output
  end

  def description
    desc = ""
    desc = @reaction_time.description if @reaction_time && @reaction_time.description
    desc
  end

  def display_id
    output = ""
    output = @reaction_time.display_id if @reaction_time && @reaction_time.display_id
    output
  end

  def find_speed_archetype_description
    desc_id = object.description_id
    if desc_id
      desc_id = desc_id.to_i 
      if desc_id > 12
        # This is only to account for older results, since we changed the descriptions since
        desc_id = 10
      end
      @reaction_time ||= SpeedArchetypeDescription.find(desc_id)
    end
  end
end