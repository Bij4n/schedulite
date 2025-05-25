RSpec.configure do |config|
  config.before(:each, type: :request) do
    allow(SmsService).to receive(:call)
    allow(GiftCardIssuanceService).to receive(:call)
  end
end
