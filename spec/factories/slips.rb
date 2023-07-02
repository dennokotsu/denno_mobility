FactoryBot.define do
  factory :slip do
    company
    name { "Name" }
    status { SLIP_STATUS_UNASSIGNED }
    targeted_at { Time.zone.now }
    user { nil } # rep_user_id
    created_user_id { create(:user).id }
    updated_user_id { create(:user).id }
    data { {} }
  end
end
