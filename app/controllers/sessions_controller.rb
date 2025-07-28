class SessionsController < ApplicationController
  REMEMBER_ME = "1".freeze

  # GET /login
  def new; end

  # POST /login
  def create
    user = User.find_by email: params.dig(:session, :email)&.downcase
    if user&.authenticate params.dig(:session, :password)
      handle_successful_login user
    else
      handle_failed_login
    end
  end

  # DELETE /logout
  def destroy
    log_out
    redirect_to root_path, status: :see_other
  end

  private

  def handle_successful_login user
    reset_session
    log_in user
    remember_cookies(user) if params.dig(:session, :remember_me) == REMEMBER_ME
    redirect_to user, status: :see_other
  end

  def handle_failed_login
    flash.now[:danger] = t(".invalid_email_password_combination")
    render :new, status: :unprocessable_entity
  end
end
