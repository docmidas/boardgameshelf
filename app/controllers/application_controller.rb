class ApplicationController < Sinatra::Base
	register Sinatra::ActiveRecordExtension

  enable :sessions

	set :database, {adapter: 'postgresql', database: 'postgres://ctgjjgdwzouwwo:HD1o5NCQPVMFo1kCcmL3ax9yu6@ec2-23-23-76-90.compute-1.amazonaws.com:5432/d70711oclki99p' }  
	set :public_folder, File.dirname(__FILE__) + '/../public'
	set :views, File.dirname(__FILE__) + '/../views'
end	
