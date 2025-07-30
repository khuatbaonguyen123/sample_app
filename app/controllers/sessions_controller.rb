class SessionsController < ApplicationController
  REMEMBER_ME = "1".freeze

  before_action :authenticate_user, only: :create
  before_action :check_activation, only: :create

  # GET /login
  def new; end

  # POST /login
  def create
    handle_successful_login @user
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end

  private

  def authenticate_user
    @user = User.find_by email: params.dig(:session, :email)&.downcase
    return if @user&.authenticate(params.dig(:session, :password))

    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity
  end

  def check_activation
    return if @user.activated?

    flash[:warning] = t(".account_not_activated")
    redirect_to root_path, status: :see_other
  end

  def handle_successful_login user
    forwarding_url = session[:forwarding_url]

    reset_session
    log_in user
    remember_cookies(user) if params.dig(:session, :remember_me) == REMEMBER_ME

    redirect_to forwarding_url || user
  end
end
