class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String, default: ''

  # Associations
  has_many :payments

  has_many :owing_splits, class_name: 'Split', inverse_of: :owing_user
  has_many :outstanding_splits, class_name: 'Split', inverse_of: :outstanding_user

  # Validations
  validates_presence_of :name

  # def owing_users
  #   User.in(id: outstanding_splits.distinct(:owing_user_id))
  # end

  # def outstanding_users
  #   User.in(id: owing_splits.distinct(:outstanding_user_id))
  # end

  def owing_splits_total
    owing_splits.map { |os| os.amount }.sum
  end

  def outstanding_splits_total
    outstanding_splits.map { |os| os.amount }.sum
  end

  def splits_total
    owing_splits_total - outstanding_splits_total
  end

  def user_wise_splits
    current_splits = {}
    User.each do |user|
      outstanding_splits_with_user = outstanding_splits.where(owing_user_id: user.id).map{ |out_split| out_split.amount }.sum
      owing_splits_with_user = owing_splits.where(outstanding_user_id: user.id).map{ |owing_split| owing_split.amount }.sum
      amount = (owing_splits_with_user - outstanding_splits_with_user)

      if amount > 0
        current_splits[user.id.to_s] ||= {}
        current_splits[user.id.to_s]['name'] = user.name
        current_splits[user.id.to_s]['amount'] = amount
      end
    end

    current_splits
  end

  def paid_events
    Event.in(id: payments.distinct(:event_id))
  end
end
