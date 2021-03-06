# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
require 'yaml'

def set_mail_configuration
  MailConfiguration.entries= {
    enable_mail_delivery: true,
    mail_host: ENV.fetch('MAIL_HOST'),
    mail_domain: ENV.fetch('MAIL_DOMAIN'),
    mail_port: ENV.fetch('MAIL_PORT'),
    mail_auth_type: 'login',
    smtp_username: ENV.fetch('SMTP_USERNAME'),
    smtp_password: ENV.fetch('SMTP_PASSWORD'),
    secure_connection_type: ENV.fetch('MAIL_SECURE_CONNECTION', 'None'),
    mails_from: ENV.fetch('MAILS_FROM', "no-reply@#{ENV.fetch('MAIL_DOMAIN')}"),
    mail_bcc: ENV.fetch('MAIL_BCC', ''),
    intercept_email: ''
  }
end
# We need mail_configuration to create a user account, because it sends a confirmation email.
set_mail_configuration

# -- Spree
unless Spree::Country.find_by_iso(ENV['DEFAULT_COUNTRY_CODE'])
  puts "[db:seed] Seeding Spree"
  Spree::Core::Engine.load_seed if defined?(Spree::Core)
  Spree::Auth::Engine.load_seed if defined?(Spree::Auth)
end

country = Spree::Country.find_by_iso(ENV['DEFAULT_COUNTRY_CODE'])
puts "Country is #{country.to_s}"

puts "[db:seed] loading states yaml"
states = YAML::load_file "db/default/spree/states.yml"
puts "States: #{states.to_s}"

# -- Seeding States
puts "[db:seed] Seeding states for " + country.name

states.each do |state|
  puts "State: " + state.to_s

  unless Spree::State.find_by_name(state['name'])
    Spree::State.create!(
      { name: state['name'], abbr: state['abbr'], country: country },
      without_protection: true
    )
  end
end

# Create users:
require File.join(File.dirname(__FILE__), 'default', 'users')

DefaultStockLocation.find_or_create
DefaultShippingCategory.find_or_create
