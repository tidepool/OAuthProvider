class FriendSerializer < ActiveModel::Serializer
  include UserNameSerialize

  attributes :id, :name, :image, :email, :friend_status

  has_one :personality
  has_many :aggregate_results, serializer: AggregateResultSerializer

  def name
    object.calculated_name
  end

end