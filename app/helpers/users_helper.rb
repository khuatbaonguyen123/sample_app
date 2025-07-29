module UsersHelper
  DEFAULT_IMAGE_SIZE = 80

  # Returns the Gravatar for the given user.
  def gravatar_for user, options = {size: DEFAULT_IMAGE_SIZE}
    size = options[:size]
    gravatar_id = Digest::MD5.hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  def gender_options_for_select
    User.genders.keys.map do |g|
      [t("users.genders.#{g}"), g]
    end
  end

  def can_destroy_user? user
    current_user.admin? && !current_user?(user)
  end
end
