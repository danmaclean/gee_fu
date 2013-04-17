if %w(development production).include?(Rails.env)
  ActionMailer::Base.smtp_settings = {
      :port =>           '587',
      :address =>        'smtp.mandrillapp.com',
      :user_name =>      ENV['MANDRILL_USERNAME'],
      :password =>       ENV['MANDRILL_APIKEY'],
      :authentication => :plain
  }
  ActionMailer::Base.delivery_method = :smtp
end