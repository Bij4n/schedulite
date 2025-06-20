require "rails_helper"

RSpec.describe DelayWorkflowTemplate, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:tenant) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:message_body) }
  end
end
