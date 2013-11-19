class FriendSerializer < ActiveModel::Serializer
  attributes :id, :name, :image, :email, :friend_status

  has_one :personality
  has_many :aggregate_results, serializer: AggregateResultSerializer

  def name
    if object.name.nil? || object.name.empty?
      object.email.split('@')[0]
    else
      object.name
    end
  end

end