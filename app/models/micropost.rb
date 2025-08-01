class Micropost < ApplicationRecord
  DIGIT_140 = 140
  DIGIT_5 = 5
  RESIZE_LIMIT = [500, 500].freeze

  MICROPOST_PERMITTED = %i(content image).freeze

  belongs_to :user

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: RESIZE_LIMIT
  end

  validates :user_id, presence: true
  validates :content, presence: true, length: {maximum: DIGIT_140}
  validates :image,
            content_type: {in: Settings.defaults.microposts.image_content_types,
                           message: :invalid_format},
            size: {less_than: DIGIT_5.megabytes,
                   message: :too_large}

  scope :recent, -> {order(created_at: :desc)}
end
