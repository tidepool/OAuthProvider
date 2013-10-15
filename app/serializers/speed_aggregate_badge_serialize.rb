module SpeedAggregateBadgeSerialize
  def badge_for_desc_id(desc_id)
    speed_archetype_desc = find_speed_archetype_description(desc_id)
    character = "Progress1"
    character = speed_archetype_desc.speed_archetype if speed_archetype_desc && speed_archetype_desc.speed_archetype
    desc = ""
    desc = speed_archetype_desc.description if speed_archetype_desc && speed_archetype_desc.description
    {
      character: character, 
      description: desc
    }
  end

  def find_speed_archetype_description(desc_id)
    speed_archetype_desc = nil
    if desc_id
      desc_id = desc_id.to_i 
      if desc_id > 12
        # This is only to account for older results, since we changed the descriptions since
        desc_id = 10
      end
      speed_archetype_desc ||= Rails.cache.fetch("SpeedArchetypeDescription_#{desc_id}", expires_in: 1.hours) do
        SpeedArchetypeDescription.find(desc_id)
      end
    end
    speed_archetype_desc
  end
end