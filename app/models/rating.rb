class Rating
  include Mongoid::Document
  include Mongoid::Timestamps

  # attr_protected :score, :editable

  field :communication, type: Integer, default: 0
  field :punctuality, type: Integer, default: 0
  field :ease_of_payment, type: Integer, default: 0
  field :over_all_experience, type: Integer, default: 0
  field :like_again, type: Integer, default: 0
  field :trip_expected, type: Boolean, default: false
  field :score, type: Float, default: 0.0
  field :editable, type: Boolean, default: false

  belongs_to :rater, class_name: "Company", inverse_of: :ratings_given
  belongs_to :ratee, class_name: "Company", inverse_of: :ratings_taken

  validates_presence_of :rater_id, on: :create, message: "can't be blank"
  validates_presence_of :ratee_id, on: :create, message: "can't be blank"
  
  validate :validate_rater_ratee
  
  before_save :calculate_score

  def lock!
    self.editable = false
    self.save()
  end

  def unlock!
    self.editable = true
    self.save()
  end

  private
  
  def validate_rater_ratee
    if rater_id == ratee_id
      errors.add :rater, "You couldn't give rate yourself."
    end
  end

  def calculate_score
    self.score = communication + punctuality + ease_of_payment + over_all_experience + like_again
    self.score = self.score / 5.0
  end

end
