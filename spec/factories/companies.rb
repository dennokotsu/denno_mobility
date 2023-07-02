FactoryBot.define do
  factory :company do
    sequence(:company_code, &:to_s)
    name { "Name" }
    data { {} }
    setting_data { Company.example_setting_data }
  end
end
