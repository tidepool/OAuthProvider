class DeviceSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :name, :os, :os_version, :token, :hardware


end