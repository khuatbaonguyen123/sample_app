class User < ApplicationRecord
  has_secure_password

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  MAX_NAME_LENGTH = 50
  MAX_EMAIL_LENGTH = 255
  HUNDRED_YEARS = 100
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

  validates :name, presence: true, length: {maximum: MAX_NAME_LENGTH}
  validates :email, presence: true, length: {maximum: MAX_EMAIL_LENGTH},
    format: {with: VALID_EMAIL_REGEX}, uniqueness: true
  validates :birthday, presence: true
  validates :gender, presence: true
  validate :birthday_within_last_100_years

  private

  def downcase_email
    email.downcase!
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
