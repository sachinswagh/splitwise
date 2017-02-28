json.extract! event, :id, :name, :event_date, :event_location, :total_amount, :participant_ids, :created_at, :updated_at
json.url event_url(event, format: :json)
