require 'bundler'

Bundler.require :default, ENV['RACK_ENV'].to_sym

# ActiveRecord::Base.establish_connection(
#     :adapter => 'sqlite3',
#     :database => 'db.sqlite3'
#   )

ActiveRecord::Base.establish_connection(
    :adapter => 'postgresql',
    :database => 'd70711oclki99p',
    :username => 'ctgjjgdwzouwwo',
    :password => 'HD1o5NCQPVMFo1kCcmL3ax9yu6'
  )

#req models
require './app/models/user'
require './app/models/game'
require './app/models/like'


#req controllers
require './app/controllers/application_controller'
require './app/controllers/users_controller'
require './app/controllers/games_controller'
require './app/controllers/home_controller'
require './app/controllers/profile_controller'


#map routes
map('/users') {run UsersController}
map('/games') {run GamesController}
map('/profile') {run ProfileController}
map('/') {run HomeController} 
