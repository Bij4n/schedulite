require "rails_helper"

RSpec.describe StatusEvent, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:appointment) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:to_status) }
  end
end
