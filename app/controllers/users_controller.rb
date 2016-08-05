class UsersController < ApplicationController

  # get '/:id/?' do |id|
  #     # get single user
  #     user = User.find(id)
  #     if user 
  #       user.to_json
  #     else
  #       {status: "ERROR", message: "Could not FIND user"}.to_json
  #     end 
  # end

  patch '/:id/?' do |id|
    #updates single cell of user
    user = User.find(id)
      if user
        user.update username: params["username"] || user.username, email: params["email"] || user.email, password: params["password"] || params.password
        #user.update params
        user.to_json
      else
        {status: "ERROR", message: "Could not UPDATE user"}.to_json
      end 
  end

  delete '/:id/?' do |id|
    #delete user
    user = User.find(id)
      if user 
        user.destroy
        {status: "Okay", message: "User DESTROYED"}.to_json
      else
        {status: "ERROR", message: "Could not DELETE user"}.to_json
      end 
  end  

  get '/?' do 
      # get all users
      users = User.all
      if users
        users.to_json    
      else
        {status: "ERROR", message: "Could not FIND ALL users"}.to_json    
      end
  end

  post '/?' do
    #create new user   
    password = BCrypt::Password.create(params["password"])
    user = User.create username: params["username"], email: params["email"], password: password

    if user          
      session[:is_logged_in] = true
      session[:user_id] = user.id
      session[:username] = user.username
      redirect to('/../profile') 
    else
      session[:message] = "Could not create user"
      redirect to("/")
    end
  end


  

  
end
