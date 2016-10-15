Mongoid::Criteria.delegate(:active_model_serializer, :to => :to_a)

ActiveModel::ArraySerializer.root = false
ActiveModel::Serializer.root(false)
