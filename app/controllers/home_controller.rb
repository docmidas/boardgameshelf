class HomeController < ApplicationController

  get '/login/?' do
    # user = User.find_by username: params["username"]
      if session[:is_logged_in]
        redirect to('/../profile')        
      else  
        erb :login
      end  
    
    
    erb :login    
  end

  get '/profile/?' do
    @games_liked = Game.where user_id: session[:user_id]
    user = User.find(session[:user_id])
      if user
        @username = user.username
      end  
     erb :profile  
     
  end


  post '/login/?' do
    user = User.find_by username: params["username"]
      if user 
        compare_to = BCrypt::Password.new(user.password)
        if compare_to == params["password"]          
          session[:is_logged_in] = true
          session[:user_id] = user.id
          # puts "isLoggedIn: #{session[:is_logged_in]}"
          redirect to('/profile') 
        else
          {status: "ERROR", message: "right user, WRONG password"}.to_json         
        end        
      else
        {status: "ERROR", message: "Could NOT find user"}.to_json
      end    
  end

  get '/' do      
    erb :register
  end  

end
