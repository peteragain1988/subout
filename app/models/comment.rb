class Comment
  include Mongoid::Document
  include Mongoid::Timestamps

  field :body, type: String
  field :commenter_name, type: String
  belongs_to :commenter, :class_name => "Company"
  embedded_in :opportunity
  validates :body, presence: true
end
