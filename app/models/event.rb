class Event
  include Mongoid::Document
  include Mongoid::Timestamps

  # Fields
  field :name, type: String, default: ''
  field :event_date, type: Time
  field :event_location, type: String, default: ''
  field :total_amount, type: Float, default: 0.0
  field :participant_ids, type: Array, default: []

  # Associations
  has_many :payments
  has_many :splits


  # Validations
  validates_presence_of :name, :total_amount, :participant_ids
  validates_length_of :participant_ids, minimum: 2

  # Methods
  def paying_users
    User.in(id: payments.distinct(:user_id))
  end

  def participants
    User.where(:_id.in => participant_ids).map{|u|u.name}.join(', ')
  end


  def create_splits
    participants_count = participant_ids.reject(&:blank?).count
    split = (total_amount.to_f / participants_count) # considering equal splits
    user_wise_payment = {}
    payments.each do |payment|
      user_wise_payment[payment.user.id.to_s] = (split - payment.amount)
    end

    while user_wise_payment.present?
      max_outstanding_user = user_wise_payment.select { |k,v| v == user_wise_payment.values.min }
      user_wise_payment.delete(max_outstanding_user.keys.first)
      user_wise_payment = user_wise_payment.sort_by{|k, v| v }.to_h
      user_wise_payment = settle(max_outstanding_user, user_wise_payment)
    end
  end # end create_splits

  def settle(max_outstanding_user, user_wise_payment)
    max_outstanding_user_amount = max_outstanding_user.values.first

    if max_outstanding_user_amount < 0
      new_user_wise_payment = user_wise_payment.dup
      paid_amount = 0
      user_wise_payment.each do |user_id, payment_amount|
        if payment_amount > 0
          rem_amount = (max_outstanding_user_amount + payment_amount)
          new_user_wise_payment[user_id] = rem_amount
          paid_amount += (payment_amount - rem_amount)

          split = self.splits.new(amount: paid_amount, owing_user_id: user_id, outstanding_user_id: max_outstanding_user.keys.first)
          split.save

          if max_outstanding_user_amount == paid_amount
            break
          end
        end
      end
    end

    new_user_wise_payment
  end
end
