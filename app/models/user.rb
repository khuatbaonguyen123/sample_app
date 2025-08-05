class User < ApplicationRecord
  has_secure_password
  attr_accessor :remember_token, :activation_token, :reset_token

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_NAME_LENGTH = 50
  MAX_EMAIL_LENGTH = 255
  MINIMUM_PASSWORD_LENGTH = 6
  HUNDRED_YEARS = 100
  RESET_EXPIRED_HOURS = 2
  USER_PERMIT = %i(
    name
    email
    birthday
    gender
    password
    password_confirmation
  ).freeze

  enum gender: {
    male: 0,
    female: 1,
    other: 2
  }, _prefix: true

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true, length: {maximum: MAX_NAME_LENGTH}
  validates :email, presence: true, length: {maximum: MAX_EMAIL_LENGTH},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: true
  validates :birthday, presence: true
  validates :gender, presence: true
  validates :password, presence: true,
    length: {minimum: MINIMUM_PASSWORD_LENGTH}, allow_nil: true
  validate :birthday_within_last_100_years

  scope :newest, -> {order(created_at: :desc)}

  has_many :microposts, dependent: :destroy

  has_many :active_relationships,
           class_name: Relationship.name,
           foreign_key: :follower_id,
           dependent: :destroy

  has_many :passive_relationships,
           class_name: Relationship.name,
           foreign_key: :followed_id,
           dependent: :destroy

  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  class << self
    def digest string
      cost = if ActiveModel::SecurePassword.min_cost
               BCrypt::Engine::MIN_COST
             else
               BCrypt::Engine.cost
             end
      BCrypt::Password.create string, cost:
    end

    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
    remember_digest
  end

  def session_token
    remember_digest || remember
  end

  def forget
    update_column :remember_digest, nil
  end

  def authenticated? attribute, token
    digest = send("#{attribute}_digest")
    return false unless digest

    BCrypt::Password.new(digest).is_password?(token)
  end

  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  # Sets the password reset attributes.
  def create_reset_digest
    self.reset_token = User.new_token
    update_attribute(:reset_digest, User.digest(reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def password_reset_expired?
    reset_sent_at < RESET_EXPIRED_HOURS.hours.ago
  end

  # Sends password reset email.
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def feed
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
             .includes(:user, image_attachment: :blob)
  end

  # Follows a user
  def follow other_user
    following << other_user
  end

  # Unfollows a user
  def unfollow other_user
    following.delete other_user
  end

  # Returns true if the current user is following the other_user
  def following? other_user
    following.include? other_user
  end

  private

  def downcase_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  def birthday_within_last_100_years
    return if birthday.blank?

    current_date = Time.zone.today
    hundred_years_ago = current_date.prev_year(HUNDRED_YEARS)

    if birthday < hundred_years_ago
      errors.add(:birthday, :in_past)
    elsif birthday > current_date
      errors.add(:birthday, :in_future)
    end
  end
end
