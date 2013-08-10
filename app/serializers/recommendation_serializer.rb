class RecommendationSerializer < ActiveModel::Serializer
  cached

  attributes :id, :big5_dimension, :sentence, :link_title, :link, :link_type, :icon_url

  def cache_key
    [object]
  end
end