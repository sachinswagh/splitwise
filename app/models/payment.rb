class Payment
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :amount, type: Float

  # Associations
  belongs_to :event
  belongs_to :user

  # Validations
  validates_presence_of :event_id, :user_id
  validates_uniqueness_of :user_id, :scope => :event_id
end
