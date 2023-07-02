FactoryBot.define do
  factory :message do
    company
    from_user_id { create(:user).id }
    to_user_id { nil }
    group_id { nil }
    data { {} }
    read { false }
    disabled { false }
  end
end
