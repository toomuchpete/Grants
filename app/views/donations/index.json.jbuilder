json.array!(@donations) do |donation|
  json.extract! donation, :id, :amount, :user_id, :comments, :internal_notes
  json.url donation_url(donation, format: :json)
end
