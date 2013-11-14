class FriendSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :email

  has_one :personality
  has_many :aggregate_results, serializer: AggregateResultSerializer

end