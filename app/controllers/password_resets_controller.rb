class PasswordResetsController < ApplicationController
  PASSWORD_RESET_PERMIT = %i(
    password
    password_confirmation
  ).freeze

  before_action :load_user_by_form_email, only: :create
  before_action :load_user_by_token_email, only: %i(edit update)
  before_action :valid_user, only: %i(edit update)
  before_action :check_expiration, only: %i(edit update)
  before_action :check_blank_password, only: :update

  # GET /password_resets/new
  def new; end

  # POST /password_resets
  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t(".notice")
    redirect_to root_path, status: :see_other
  end

  # GET /password_resets/:id/edit
  def edit; end

  # PATCH /password_resets/:id
  def update
    if @user.update user_params.merge(reset_digest: nil)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  private

  def load_user_by_form_email
    @user = User.find_by email: params.dig(:password_reset, :email)&.downcase
    return if @user

    flash.now[:danger] = t(".failure")
    render :new, status: :unprocessable_entity
  end

  def load_user_by_token_email
    @user = User.find_by email: params[:email]&.downcase
    return if @user

    flash[:danger] = t("password_resets.load_user.user_not_found")
    redirect_to root_path, status: :see_other
  end

  def valid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    flash[:danger] = t("password_resets.valid_user.invalid_user")
    redirect_to root_path, status: :see_other
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t("password_resets.check_expiration.expired")
    redirect_to new_password_reset_path, status: :see_other
  end

  def check_blank_password
    return if user_params[:password].present?

    @user.errors.add :password, t(".blank_password")
    render :edit, status: :unprocessable_entity
  end

  def handle_successful_update
    log_in @user
    flash[:success] = t(".success")
    redirect_to @user, status: :see_other
  end

  def handle_failed_update
    flash.now[:danger] = t(".failure")
    render :edit, status: :unprocessable_entity
  end

  def user_params
    params.require(:user).permit PASSWORD_RESET_PERMIT
  end
end
