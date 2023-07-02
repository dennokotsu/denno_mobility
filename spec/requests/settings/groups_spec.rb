require "rails_helper"

RSpec.describe Settings::GroupsController, type: :request do
  sign_in_user_admin

  describe "GET /settings/groups" do
    subject { get settings_groups_path }

    it do
      subject
      expect(response.status).to eq 200
    end

    context "with a group" do
      before do
        company = current_company
        group = create(:group, company:)
        get settings_groups_path(group)
      end

      it do
        subject
        expect(response.status).to eq 200
      end
    end
  end

  describe "GET /settings/groups/new" do
    before { get new_settings_group_path }

    it { expect(response.status).to eq 200 }
  end

  describe "POST /settings/groups" do
    let(:name) { "Name" }

    subject { post settings_groups_path, params: { group: { name: } } }

    it { expect { subject }.to change { Group.count }.by 1 }

    context "with invalid params (empty name)" do
      let(:name) { "" }

      before { subject }

      it { expect(response.status).to eq 422 }
    end
  end

  describe "POST /settings/groups" do
    before do
      post settings_groups_path, params: { group: { name: "Name" }, target_user_ids: ["1"] }
    end

    it { expect(response.status).to eq 303 }
  end

  describe "GET /settings/groups/:id/edit" do
    before do
      company = current_company
      group = create(:group, company:)
      get edit_settings_group_path(group)
    end

    it { expect(response.status).to eq 200 }
  end

  describe "PUT /settings/groups/:id" do
    before { @group = create :group, company: current_company }

    subject { put settings_group_path(@group), params: { group: { name: "Updated name" } } }

    it do
      subject
      @group.reload
      expect(@group.name).to eq "Updated name"
    end
  end

  describe "PUT /settings/groups/:id with target_user_ids" do
    before { @group = create :group, company: current_company }

    subject { put settings_group_path(@group), params: { group: { name: "Updated name" }, target_user_ids: ["1"] } }

    it do
      subject
      @group.reload
      expect(@group.name).to eq "Updated name"
    end
  end

  describe "DELETE /settings/groups/:id" do
    before { @group = create :group, company: current_company }

    subject { delete settings_group_path(@group) }

    it { expect { subject }.to change { Group.count }.by(-1) }
  end
end
