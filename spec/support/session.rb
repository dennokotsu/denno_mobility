RSpec.configure do |_config|
  def sign_in_user
    let(:__prevented_by_sign_out_user) { false }

    before do
      next if __prevented_by_sign_out_user

      user = create :user
      session = { company_code: user.company.company_code, identifier: user.identifier, password: user.password }
      post login_path, params: { session: }
      @__private_keep_user = user
    end

    let(:current_user) { @__private_keep_user }
    let(:current_company) { @__private_keep_user.company }
  end

  def sign_out_user
    let(:__prevented_by_sign_out_user) { true }
    let(:current_user) { nil }
    let(:current_company) { nil }
  end

  def sign_in_user_admin
    let(:__prevented_by_sign_out_user_admin) { false }

    before do
      next if __prevented_by_sign_out_user_admin

      user = create :user, :admin
      session = { company_code: user.company.company_code, identifier: user.identifier, password: user.password }
      post login_path, params: { session: }
      @__private_keep_user_admin = user
    end

    let(:current_user) { @__private_keep_user_admin }
    let(:current_company) { @__private_keep_user_admin.company }
  end

  def sign_out_user_admin
    let(:__prevented_by_sign_out_user_admin) { true }
    let(:current_user) { nil }
    let(:current_company) { nil }
  end
end
