module Portal
  class AppointmentsController < BaseController
    before_action :authenticate_patient!

    def index
      ActsAsTenant.with_tenant(current_patient.tenant) do
        @upcoming = current_patient.appointments
          .where("starts_at >= ?", Time.current)
          .order(:starts_at)
          .limit(20)

        @past = current_patient.appointments
          .where("starts_at < ?", Time.current)
          .order(starts_at: :desc)
          .limit(10)
      end
    end
  end
end
