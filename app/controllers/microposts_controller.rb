class MicropostsController < ApplicationController
  PAGE_LIMIT = 10

  # Ensure user is logged in for create and destroy actions
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  # GET /microposts
  def index
    @microposts = Micropost.recent
  end

  # POST /microposts
  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      handle_success_save
    else
      handle_failure_save
    end
  end

  # DELETE /microposts/:id
  def destroy
    if @micropost.destroy
      flash[:success] = t(".success_message")
    else
      flash[:danger] = t(".failure_message")
    end
    redirect_to request.referer || root_url
  end

  private

  def micropost_params
    params.require(:micropost).permit(Micropost::MICROPOST_PERMITTED)
  end

  def handle_success_save
    flash[:success] = t(".success_message")
    redirect_to root_url, status: :see_other
  end

  def handle_failure_save
    flash.now[:danger] = t(".failure_message")

    @pagy, @feed_items = pagy current_user.feed, items: PAGE_LIMIT,
    limit: PAGE_LIMIT
    render "static_pages/home", status: :unprocessable_entity
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:danger] = t(".not_found")
    redirect_to request.referer || root_url
  end
end
