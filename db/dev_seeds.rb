# rubocop:disable Layout/LineLength
if Company.count.zero?
  company = Company.create company_code: "example", name: "Company 1", setting_data: Company.example_setting_data
  User.create company_id: company.id, identifier: "user1", password: "password", name: "User 1", role: USER_ROLE_ADMIN, data: { "attribute" => { "email" => "1@example.com" } }
  User.create company_id: company.id, identifier: "user2", password: "password", name: "User 2", role: USER_ROLE_USER, data: { "attribute" => { "email" => "2@example.com" } }
end
# rubocop:enable Layout/LineLength
