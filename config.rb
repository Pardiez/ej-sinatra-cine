configure ENV['RACK_ENV'].to_sym do
  set "email_options", {
    :via => :smtp,
    :via_options => {
      :address              => ENV['EMAIL_ADDRESS'],
      :domain               => ENV['EMAIL_DOMAIN'],
      :port                 => '587',
      :user_name            => ENV['EMAIL_USERNAME'],
      :password             => ENV['EMAIL_PASSWORD'],
      :authentication       => :plain,
      :enable_starttls_auto => true
    }
  }
end