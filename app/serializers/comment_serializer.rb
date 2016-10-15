class CommentSerializer < ActiveModel::Serializer
  attributes :_id, :commenter_name, :body, :created_at
end
