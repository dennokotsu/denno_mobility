require "rails_helper"

RSpec.describe SlipsController, type: :request do
  sign_in_user

  describe "GET /slips" do
    before { get slips_path }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /slips/:id" do
    let(:user) { current_user }

    before do
      slip = create(:slip, company: current_company, user:)
      get slip_path(slip)
    end

    it { expect(response.status).to eq 200 }

    context "Other user's" do
      let(:user) { create :user }

      it { expect(response.status).to eq 303 }
    end
  end

  describe "GET /slips/new" do
    before { get new_slip_path }

    it { expect(response.status).to eq 303 }
  end

  describe "POST /slips" do
    before { post slips_path }

    it { expect(response.status).to eq 303 }
  end

  describe "GET /slips/edit" do
    before do
      slip = create :slip, company: current_company, user: current_user
      get edit_slip_path(slip)
    end

    it { expect(response.status).to eq 200 }
  end

  describe "PUT /slips/:id" do
    before do
      another_user = create :user
      @slip = create :slip, company: current_company, user: another_user
      put slip_path(@slip)
    end

    it { expect(response.status).to eq 303 }
  end

  describe "DELETE /slips/:id" do
    before do
      slip = create :slip, company: current_company
      delete slip_path(slip)
    end

    it { expect(response.status).to eq 303 }
  end
end
