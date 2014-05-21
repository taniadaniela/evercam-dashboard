#! /usr/bin/env ruby

require 'dotenv'
require 'sequel'

Dotenv.load
Sequel::Model.db = Sequel.connect("#{ENV['DATABASE_URL']}?pool=25")

require 'evercam_misc'
require 'evercam_models'
require 'intercom'

Intercom.app_id = 'f9c1fd60de50d31bcbc3f4d8d74c9c6dbc40e95a'
Intercom.api_key = 'e07f964835e66a91d356be0171895dea792c3c4b'

User.all.each do |u|
  puts "Email: #{u.email}"
  begin
    user = Intercom::User.find(:email => u.email)
    if user.name.nil?
      puts "No name, our name: #{u.fullname}"
      user.name = u.fullname
      user.save
      puts 'Updated!'
    else
      puts user.name
    end
  rescue Intercom::ResourceNotFound
    puts 'Not found in intercom'
  end
  puts '---------'
end
