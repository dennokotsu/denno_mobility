require "rails_helper"

RSpec.describe SlipsController, type: :request do
  sign_in_user_admin

  describe "GET /slips" do
    before { get slips_path }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /slips with target_day" do
    before { get slips_path, params: { target_day: Date.today } }

    it { expect(response.status).to eq 200 }
  end

  describe "GET /slips/:id" do
    before do
      slip = create :slip, company: current_company
      get slip_path(slip)
    end

    it { expect(response.status).to eq 200 }
  end

  describe "GET /slips/new" do
    before { get new_slip_path }

    it { expect(response.status).to eq 200 }
  end

  describe "POST /slips" do
    subject do
      user = create :user, company: current_company
      slip = { name: "Name", targeted_at: "2022-01-01T00:00:00+00:00", rep_user_id: user.id }
      slip.merge!(company_setting_data_slip_attribute_required_defaults(current_company))
      post slips_path, params: { slip: }
    end

    it { expect { subject }.to change { Slip.count }.by 1 }
  end

  describe "GET /slips/edit" do
    before do
      slip = create :slip, company: current_company
      get edit_slip_path(slip)
    end

    it { expect(response.status).to eq 200 }
  end

  describe "PUT /slips/:id" do
    before do
      @slip = create :slip, company: current_company
    end

    subject do
      @another_user = create :user, company: current_company
      slip = { name: "Name Updated", targeted_at: "2022-01-02T00:00:00+00:00", rep_user_id: @another_user.id }
      slip.merge!(company_setting_data_slip_attribute_required_defaults(current_company))
      put slip_path(@slip), params: { slip: }
    end

    it do
      subject
      @slip.reload
      expect(@slip.name).to eq "Name Updated"
      expect(@slip.targeted_at).to eq "2022-01-02T00:00:00+00:00"
      expect(@slip.rep_user_id).to eq @another_user.id
    end
  end

  describe "PUT /slips/:id(status)" do
    before do
      @slip = create :slip, company: current_company
    end

    it "status accept" do
      put slip_path(@slip), params: { id: @slip.id, status: "accept" }
      @slip.reload
      expect(@slip.status).to eq(SLIP_STATUS_ACCEPT)
    end

    it "status reject" do
      put slip_path(@slip), params: { id: @slip.id, status: "reject" }
      @slip.reload
      expect(@slip.status).to eq(SLIP_STATUS_REJECT)
    end

    it "status pickup" do
      put slip_path(@slip), params: { id: @slip.id, status: "pickup" }
      @slip.reload
      expect(@slip.status).to eq(SLIP_STATUS_PICKUP)
    end

    it "status deliver" do
      put slip_path(@slip), params: { id: @slip.id, status: "deliver" }
      @slip.reload
      expect(@slip.status).to eq(SLIP_STATUS_DELIVER)
    end

    it "status complete" do
      put slip_path(@slip),
        params: { id: @slip.id, status: "complete", slip: { get_off_distance: 10, get_off_payment: 1000 } }
      @slip.reload
      expect(@slip.status).to eq(SLIP_STATUS_COMPLETE)
    end
  end

  describe "DELETE /slips/:id" do
    before { @slip = create :slip, company: current_company }

    subject { delete slip_path(@slip) }

    it { expect { subject }.to change { Slip.count }.by(-1) }
  end
end
