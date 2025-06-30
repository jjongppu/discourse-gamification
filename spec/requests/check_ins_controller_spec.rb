require "rails_helper"

RSpec.describe DiscourseGamification::CheckInsController do
  fab!(:user)

  before { SiteSetting.discourse_gamification_enabled = true }

  it "awards points once per day" do
    sign_in(user)

    post "/gamification/check-in.json"
    expect(response.status).to eq(200)
    expect(response.parsed_body["points_awarded"]).to eq(true)

    post "/gamification/check-in.json"
    expect(response.parsed_body["points_awarded"]).to eq(false)
  end
end
