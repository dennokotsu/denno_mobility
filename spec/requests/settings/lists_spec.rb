require "rails_helper"

RSpec.describe Settings::ListsController, type: :request do
  sign_in_user

  describe "GET /settings/lists" do
    before { get settings_lists_path }

    it { expect(response.status).to eq 200 }
  end
end
