require "rails_helper"

RSpec.describe Api::GeoController, type: :request do
  sign_in_user

  describe "POST /api/geo" do
    before { @user_id = current_user.id }

    # assertion
    it { expect(User.find(@user_id).position).to be_nil }

    let(:lat) { "0.0" }
    let(:lng) { "0.0" }

    subject { post api_geo_index_path, params: { lat:, lng: } }

    it do
      new_position = RGeo::Cartesian.simple_factory(srid: 4612, uses_lenient_assertions: true).point(0.0, 0.0)
      expect { subject }.to change { User.find(@user_id).position }.to new_position
    end

    it do
      subject
      expect(JSON.parse(response.body)).to eq({ "success" => true })
    end

    context do
      let(:lat) { "" }
      let(:lng) { "" }

      it { expect { subject }.not_to change { User.find(@user_id).position } }

      it do
        subject
        expect(JSON.parse(response.body)).to eq({ "success" => false })
      end
    end
  end
end
