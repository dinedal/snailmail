if Snailmail::SENDGRID_USERNAME &&
    Snailmail::SENDGRID_PASSWORD &&
    Snailmail::ADMIN_EMAIL
  Snailmail::EMAIL_ENABLED = true

  Pony.options = {
    :to   => Snailmail::ADMIN_EMAIL,
    :from => Snailmail::SENDGRID_USERNAME,
    :via  => :smtp,
    :via_options => {
      :address => 'smtp.sendgrid.net',
      :port => '587',
      :domain => 'heroku.com',
      :user_name => ENV['SENDGRID_USERNAME'],
      :password => ENV['SENDGRID_PASSWORD'],
      :authentication => :plain,
      :enable_starttls_auto => true
    }
  }
else
    Snailmail::EMAIL_ENABLED = false
end
