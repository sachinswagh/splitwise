class Split
  include Mongoid::Document
  include Mongoid::Document

  # Fields
  field :event_id, type: String
  field :amount, type: Float

  # Associations
  belongs_to :event

  belongs_to :owing_user, class_name: 'User', inverse_of: :owing_splits
  belongs_to :outstanding_user, class_name: 'User', inverse_of: :outstanding_splits

  # Validations
  validates_presence_of :event_id, :owing_user_id, :outstanding_user_id
  validates_uniqueness_of :event_id, :scope => [:owing_user_id, :outstanding_user_id]
end
