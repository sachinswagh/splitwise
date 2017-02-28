json.extract! payment, :id, :event_id, :user_id, :amount, :created_at, :updated_at
json.url payment_url(payment, format: :json)
