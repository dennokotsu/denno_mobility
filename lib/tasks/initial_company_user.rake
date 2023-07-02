require "securerandom"

namespace :db do
  desc "Create a company and an admin user"
  task :initial_company_user, %w[name company_code] => :environment do |_task, args|
    name = args.name
    company_code = args.company_code
    company = Company.create!(company_code:, name:, data: {}, setting_data: Company.example_setting_data)

    identifier = "company_#{company.id}_admin"
    password = SecureRandom.hex(32)
    name = "#{company.name} Administrator"
    User.create!(company:, identifier:, password:, role: USER_ROLE_ADMIN, name:, data: {})

    puts "事業者ID: #{company_code}"
    puts "ユーザーID: #{identifier}"
    puts "パスワード: #{password}"
  rescue StandardError => e
    p e
    company&.destroy
  end
end
