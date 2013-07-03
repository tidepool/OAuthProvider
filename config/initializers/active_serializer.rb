ActiveSupport.on_load(:active_model_serializers) do
  # self.root = false
  # Disable for all serializers (except ArraySerializer)
  ActiveModel::Serializer.root = false

  # Disable for ArraySerializer
  ActiveModel::ArraySerializer.root = false
end