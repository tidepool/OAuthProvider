class RecommendationSerializer < ActiveModel::Serializer
  attributes :id, :big5_dimension, :sentence, :link_title, :link, :link_type, :icon_url

end