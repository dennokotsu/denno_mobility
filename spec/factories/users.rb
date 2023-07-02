FactoryBot.define do
  factory :user do
    company

    sequence(:identifier, &:to_s)
    password { "password" }
    name { "Name" }
    role { USER_ROLE_USER }
    data { {} }

    trait :admin do
      role { USER_ROLE_ADMIN }
    end
  end
end
