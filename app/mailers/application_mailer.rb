class ApplicationMailer < ActionMailer::Base
  default from: Settings.defaults.mailer.email_from_address
  layout Settings.defaults.mailer.mailer_layout
end
