require 'bundler'
Bundler.require()

get '/' do
  {:message => 'hello, world!'}.to_json
end