class StaticPagesController < ApplicationController
  PAGE_LIMIT = 10

  def home
    return unless logged_in?

    @micropost = current_user.microposts.build
    @pagy, @feed_items = pagy current_user.feed.recent
                                          .with_attached_image
                                          .includes(:user),
                              items: PAGE_LIMIT,
                              limit: PAGE_LIMIT
  end

  def help; end

  def contact; end
end
