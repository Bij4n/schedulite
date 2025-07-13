module Portal
  class BaseController < ActionController::Base
    protect_from_forgery with: :exception
    layout "landing"

    helper_method :current_patient

    private

    def current_patient
      @current_patient ||= Patient.find_by(id: session[:patient_id]) if session[:patient_id]
    end

    def authenticate_patient!
      redirect_to portal_login_path unless current_patient
    end

    def sign_in_patient(patient)
      session[:patient_id] = patient.id
    end

    def sign_out_patient
      session.delete(:patient_id)
      @current_patient = nil
    end
  end
end
