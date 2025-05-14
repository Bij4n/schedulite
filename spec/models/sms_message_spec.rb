require "rails_helper"

RSpec.describe SmsMessage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:appointment) }
    it { is_expected.to belong_to(:patient) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:direction) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe "direction enum" do
    it { is_expected.to define_enum_for(:direction).with_values(inbound: 0, outbound: 1) }
  end
end
