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

  get '/register/?' do
      if session[:is_logged_in]
        redirect to('/../profile')        
      else  
        erb :register
      end        
  end

  get '/profile/?' do
    if !session[:is_logged_in]
      redirect to('/')
    else
      @games_liked = Game.where user_id: session[:user_id]
      user = User.find(session[:user_id])
      if user
        @username = user.username
      end  
     erb :profile
    end  
       
  end

  get '/signout/?' do    
      session[:is_logged_in] = false
      session[:user_id] = nil
      redirect to('/')
  end


  post '/login/?' do
    user = User.find_by username: params["username"]
      if user 
        compare_to = BCrypt::Password.new(user.password)
        if compare_to == params["password"]          
          session[:is_logged_in] = true
          session[:user_id] = user.id
          session[:username] = user.username

          # puts "isLoggedIn: #{session[:is_logged_in]}"
          redirect to('/profile') 
        else
          # {status: "ERROR", message: "right user, WRONG password"}.to_json
          session[:message] = "username exists, but WRONG password"
          redirect to("/")         
        end        
      else
        # {status: "ERROR", message: "Could NOT find user"}.to_json
        session[:message] = "Could NOT find user"
        redirect to("/")
      end    
  end

  get '/' do      
    if session[:is_logged_in]
        redirect to('/../profile')        
      else  
        erb :login
      end  
  end  

end
