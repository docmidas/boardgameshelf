require 'httparty'
require 'json'

class ProfileController < ApplicationController
#####turn string keys to hash
  def symbolize(obj)
    return obj.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = symbolize(v) }
    end if obj.is_a? Hash    
      return obj.reduce([]) do |memo, v| 
        memo << symbolize(v); memo
      end if obj.is_a? Array      
      obj
  end
############################ 
#### asks GEEK API for a single or multi IDs, separated by a comma and then ...
#####posts to my /local
### add a game like
post '/geekapi/?' do

  p '-----------------------------'
  p params
  p session[:user_id]
  p '-----------------------------'
  #response = HTTParty.get("http://www.boardgamegeek.com/xmlapi2/thing?id=124742&stats=1&ratingcomments=1")
  boardgamegeekApi2 = "http://www.boardgamegeek.com/xmlapi2/thing?id="
  geekId = params["geekId"]
  geekArgs = "&stats=1&ratingcomments=1"
  response = HTTParty.get(boardgamegeekApi2 + geekId + geekArgs)
  puts "==============START=================="
  respP = response.parsed_response ###httparty method
  respP = symbolize(respP)###method symbolize defined at top for all of controller
  puts respP

# binding.pry
##### grab primary title
  if respP[:items][:item][:name].class == Array
    respP[:items][:item][:name].each do |entry|
         if entry[:type]== "primary"  
         # if entry["item"]== "primary"          
           puts "Game name is: #{entry[:value]}"
           @name = entry[:value] 
         end  
    end   
  else
    @name = respP[:items][:item][:name][:value]
  end
##############  
  # puts "Image URL: #{respP[:items][:item][:image].sub("//", "")}"
  @image = respP[:items][:item][:image] ? respP[:items][:item][:image].sub("//", "") : "upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/300px-No_image_available.svg.png"

####################CHARACTERistics not needed for LIKES for this version atm
  # boardgamelinks = []       #####prep characteristic arrays
  # boardgamecategory = []
  # boardgamemechanic = []
  # boardgamefamily = []
  # boardgamedesigner = []

  # respP[:items][:item][:link].each do |entry|
  #   if entry[:type] == "boardgamecategory"
  #     boardgamecategory.push(entry[:value])    
  #   elsif entry[:type] == "boardgamemechanic"
  #     boardgamemechanic.push(entry[:value])
  #   elsif entry[:type] == "boardgamefamily"
  #     boardgamefamily.push(entry[:value])
  #   elsif entry[:type] == "boardgamedesigner"
  #     boardgamedesigner.push(entry[:value])
  #   end
  # end

  # # puts "Categories: #{boardgamecategory}"
  # # puts "Mechanics: #{boardgamemechanic}"
  # # puts "Family: #{boardgamefamily}"
  # # puts "Designer: #{boardgamedesigner}"

  #   @boardgamecategory = boardgamecategory[0] || nil
  #   @boardgamemechanic = boardgamemechanic[0] || nil
  #   # @designer = boardgamedesigner.join(", ") || nil

  #   @designer = boardgamedesigner[0]|| nil

 ###########end of characteristics
 ########################   
    
    @weight = respP[:items][:item][:statistics][:ratings][:averageweight][:value]
    # puts "averageweight: #{averageweight}"
    @playtime = respP[:items][:item][:playingtime][:value]
    # puts "Playtime: #{playingtime}"
    @description = respP[:items][:item][:description] ? respP[:items][:item][:description] : "No description"
    # puts description
    @geekId = respP[:items][:item][:id]

    dateAdded = DateTime.now
    yearAdjusted = dateAdded.year * 1000
    @scrape_date = yearAdjusted + DateTime.now.yday #####YYYYDDD
    # puts date_adjusted
    @user_id = session[:user_id]
 

      def add_like
          HTTParty.post("http://localhost:9292/profile/", body: {name: @name, geekId: @geekId, image: @image, scrape_date: @scrape_date, weight: @weight, playtime: @playtime, description: @description, user_id: @user_id})
            # puts "#{@name}, #{@boardgamemechanic}, #{@boardgamecategory}"
      end 

      def get_games
        # HTTParty.get("http://localhost:9292/games/")
            # puts "#{@name}, #{@boardgamemechanic}, #{@boardgamecategory}"
      end 
      
    puts "Trying to add LIKE"
    add_like()


    # puts "Trying to GET games"
    # get_games()
    puts "====================FINISH=================="
@games_liked = Like.where user_id: session[:user_id]

 erb :profile
end
#######################
###DELETE#####remove a like form profile
  post '/deletelike/?' do
    like = Like.find_by geek_id: params["geekId"]
    puts like.name
    if like 
        like.destroy
        # {status: "Okay", message: "Game DESTROYED"}.to_json
        redirect to("/../")
      else
        {status: "ERROR", message: "Could not DELETE game"}.to_json
      end  
  end
#####################  
#####UPDATE 
####Dex, really don't need an update for profile at this point
  # patch '/:id/?' do |id|
  #   game = Game.find(id)   
  #   if game 
  #       game.update name: params["name"] || game["name"], theme: params["theme"] || game["theme"], category: params["category"] || game["category"]
  #       {status: "Okay", message: "Game UPDATED"}.to_json
  #     else
  #       {status: "ERROR", message: "Could not UPDATE game"}.to_json
  #     end    
  # end
##########################
#####   load profile page and show all user likes
  get '/?' do
    if !session[:is_logged_in]
      redirect to('/../') ###back to root
    else
      @games_liked = Like.where user_id: session[:user_id]
      user = User.find(session[:user_id])
      if user
        @username = user.username
      end  
      erb :profile
    end  
  end
################
###CREATE NEW LIKE ENTRY
  post '/?' do
    Like.where(geek_id: params["geekId"], user_id: params["user_id"]).first_or_create do |like|
      like.name = params["name"]
      like.geek_id = params["geekId"]
      like.img_src = params["image"]
      like.scrape_date = params["scrape_date"]
      like.weight = params["weight"]
      like.playtime = params["playtime"]
      like.description = params["description"]
      like.user_id = params["user_id"]    
    end   
  end
end 
