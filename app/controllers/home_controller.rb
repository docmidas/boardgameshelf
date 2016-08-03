class HomeController < ApplicationController



  get '/login/?' do
    @games_liked = Game.where user_id: session[:user_id]
    erb :login    
  end

  get '/profile/?' do
    @games_liked = Game.where user_id: session[:user_id]
    erb :profile    
  end


  post '/login/?' do
    user = User.find_by username: params["username"]
      if user 
        compare_to = BCrypt::Password.new(user.password)
        if compare_to == params["password"]
          @username = params["username"]
          @password = user["password"]
          @email = user["email"]
          
          session[:is_logged_in] = true
          session[:user_id] = user.id

          puts "isLoggedIn: #{session[:is_logged_in]}"

          @games_liked = Game.where user_id: session[:user_id]
          # {status: "Okay", message: "Found USER! #{user.username}"}.to_json
          erb :profile
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
