class SpeedAggregateResultSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :type, :scores, :high_scores, :last_speed_archetype

  def initialize(object, options={})
    super 
    find_speed_archetype_description
  end

  def last_speed_archetype
    output = "Progress1"
    output = @reaction_time.speed_archetype if @reaction_time && @reaction_time.speed_archetype
    output
  end

  def find_speed_archetype_description
    desc_id = object.last_description_id
    if desc_id
      desc_id = desc_id.to_i 
      if desc_id > 12
        # This is only to account for older results, since we changed the descriptions since
        desc_id = 10
      end
      @reaction_time ||= Rails.cache.fetch("SpeedArchetypeDescription_#{desc_id}", expires_in: 1.hours) do
        SpeedArchetypeDescription.find(desc_id)
      end
    end
  end


end