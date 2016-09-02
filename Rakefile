require 'bundler/setup'
require "sinatra/activerecord/rake"

###Works in dev
# ActiveRecord::Base.establish_connection(
#     :adapter => 'sqlite3',
#     :database => 'db.sqlite3'
#   )

require 'yaml'

database_cxn = YAML.load_file('./config/database.yml')

ActiveRecord::Base.establish_connection database_cxn[ENV['RACK_ENV']]


# ActiveRecord::Base.establish_connection(
#     :adapter => 'postgresql',
#     :database => 'postgres://ctgjjgdwzouwwo:HD1o5NCQPVMFo1kCcmL3ax9yu6@ec2-23-23-76-90.compute-1.amazonaws.com:5432/d70711oclki99p'
#   )

#:database => 'heroku pg:psql --app boardgameshelf DATABASE',

# ActiveRecord::Base.establish_connection(
#     :adapter => 'postgresql',
#     :database => 'postgres://ctgjjgdwzouwwo:HD1o5NCQPVMFo1kCcmL3ax9yu6@ec2-23-23-76-90.compute-1.amazonaws.com:5432/d70711oclki99p',
#     :username => 'ctgjjgdwzouwwo',
#     :password => 'HD1o5NCQPVMFo1kCcmL3ax9yu6'
#   )
