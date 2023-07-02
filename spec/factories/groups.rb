FactoryBot.define do
  factory :group do
    company
    name { "Name" }
    disabled { false }
    data { nil }
  end
end
