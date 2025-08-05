class UsersController < ApplicationController
  PAGE_LIMIT = 10

  before_action :logged_in_user, only: %i(show edit update destroy index)
  before_action :load_user, only: %i(show edit update destroy)
  before_action :correct_user, only: %i(show edit update)
  before_action :admin_user, only: :destroy

  # GET /signup
  def new
    @user = User.new
  end

  # GET /users/:id
  def show
    @page, @microposts = pagy @user.microposts
                                   .recent
                                   .includes(:user)
                                   .with_attached_image,
                              items: PAGE_LIMIT,
                              limit: PAGE_LIMIT
  end

  # POST /signup
  def create
    @user = User.new user_params

    if @user.save
      handle_successful_signup
    else
      handle_failed_signup
    end
  end

  # GET /users/:id/edit
  def edit; end

  # PATCH /users/:id
  def update
    if @user.update(user_params)
      handle_successful_update
    else
      handle_failed_update
    end
  end

  # GET /users
  def index
    @pagy, @users = pagy(User.newest, items: PAGE_LIMIT, limit: PAGE_LIMIT)
  end

  # DELETE /users/:id
  def destroy
    if @user.destroy
      flash[:success] = t(".success_message")
    else
      flash[:danger] = t(".error_message")
    end

    redirect_to users_path, status: :see_other
  end

  private

  def user_params
    params.require(:user).permit User::USER_PERMIT
  end

  def load_user
    @user = User.find_by(id: params[:id])
    return if @user

    flash[:warning] = t("users.load_user.not_found")
    redirect_to root_path
  end

  def correct_user
    return if current_user?(@user) || current_user.admin?

    flash[:danger] = t("users.current_user.not_authorized")
    redirect_to root_path, status: :see_other
  end

  def admin_user
    return if current_user.admin?

    flash[:danger] = t("users.admin_user.not_authorized")
    redirect_to root_path, status: :see_other
  end

  def handle_successful_signup
    @user.send_activation_email
    flash[:info] = t(".check_email")
    redirect_to root_path, status: :see_other
  end

  def handle_failed_signup
    render :new, status: :unprocessable_entity
  end

  def handle_successful_update
    flash[:success] = t(".success_message")
    redirect_to @user, status: :see_other
  end

  def handle_failed_update
    render :edit, status: :unprocessable_entity
  end
end
