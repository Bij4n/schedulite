class RegistrationsController < ApplicationController
  skip_before_action :set_tenant
  layout "landing"

  def new
  end

  def create
    tenant = Tenant.new(
      name: params.dig(:registration, :practice_name),
      subdomain: params.dig(:registration, :subdomain),
      plan: "free",
      trial_ends_at: 14.days.from_now
    )

    user = tenant.users.build(
      first_name: params.dig(:registration, :first_name),
      last_name: params.dig(:registration, :last_name),
      email: params.dig(:registration, :email),
      password: params.dig(:registration, :password),
      role: :owner
    )

    if tenant.save
      sign_in(user)
      redirect_to root_path, notice: "Welcome to Schedulite!"
    else
      render :new, status: :unprocessable_entity
    end
  end
end
