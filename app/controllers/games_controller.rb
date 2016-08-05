require 'httparty'
require 'json'

class GamesController < ApplicationController
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
#GAME NAME SEARCH
post '/search/?' do
  ##### CHECK FOR FORM FILL
  if params["name"] == ""
    session[:message] = "Please enter a boardgame title to search"
    # erb :search_results
    redirect to('/../profile')
  end  
  

  searchname = params["name"]
  boardgamegeekApiSearch = "http://www.boardgamegeek.com/xmlapi2/search?query=#{searchname}&type=boardgame"
  puts "==============START====Attempting to serach by title" 
  response = HTTParty.get(boardgamegeekApiSearch)
  respP = response.parsed_response #####parse xml to hash

  respP = symbolize(respP) #####symbolize string keys

 if respP[:items][:total] == "0"
  session[:message] = "No results found"  
  redirect to('/../profile') 
 end 

 search_results = [] ###prepare search results
 

 if respP[:items][:item].class == Array
  puts "Results are array"
  
    respP[:items][:item].each do |entry|         
     @name = entry[:name][:value] 
     @geekId = entry[:id] 
     # puts "#{count} result is good geekId #{@geekId} with yP class of #{entry[:yearpublished].class} and yP of #{entry[:yearpublished]}"

     @yearPublished = entry[:yearpublished] ? entry[:yearpublished][:value] : 0 ###some entries don't have yearPublished val whch crashes
     search_results.push({name: @name, geekId: @geekId, yearPublished: @yearPublished})   
    end 
  else
    @name = respP[:items][:item][:name][:value] 
    @geekId = respP[:items][:item][:id]  
    @yearPublished = respP[:items][:item][:yearpublished] ? respP[:items][:item][:yearpublished][:value] : 0 
    search_results.push({name: @name, geekId: @geekId, yearPublished: @yearPublished}) 
  end

  @search_results = search_results
  erb :search_results
end 
#########==end game search 
##################################
####Add game to my game inventory
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

  # binding.pry
  puts "This is the response CLASS #{respP.class}"



def addSingleGame(respP_entry)
####  
 
  if respP_entry[:name].class == Array  # grab primary title
    respP_entry[:name].each do |entry|
         if entry[:type]== "primary"  
         # if entry["item"]== "primary"          
           puts "Game name is: #{entry[:value]}"
           @name = entry[:value] 
         end  
    end   
  else
    @name = respP_entry[:name][:value]
  end
##############  
  # puts "Image URL: #{respP_entry[:image].sub("//", "")}"
  @image = respP_entry[:image]? respP_entry[:image].sub("//", "") : "No image"

  boardgamelinks = []       #####prep characteristic arrays
  boardgamecategory = []
  boardgamemechanic = []
  boardgamefamily = []
  boardgamedesigner = []

  if respP_entry[:link]
    respP_entry[:link].each do |entry|
      if entry[:type] == "boardgamecategory"
        boardgamecategory.push(entry[:value])    
      elsif entry[:type] == "boardgamemechanic"
        boardgamemechanic.push(entry[:value])
      elsif entry[:type] == "boardgamefamily"
        boardgamefamily.push(entry[:value])
      elsif entry[:type] == "boardgamedesigner"
        boardgamedesigner.push(entry[:value])
      end
    end
  end 

    @boardgamecategory = boardgamecategory[0] || nil
    @boardgamemechanic = boardgamemechanic[0] || nil
    # @designer = boardgamedesigner.join(", ") || nil
    @designer = boardgamedesigner[0]|| nil
    @weight = respP_entry[:statistics][:ratings][:averageweight][:value]
    # puts "averageweight: #{averageweight}"

    @playtime = respP_entry[:playingtime][:value]
    # puts "Playtime: #{playingtime}"

    @description = respP_entry[:description]
    # puts description

    @geekId = respP_entry[:id]
    # puts "geekId: #{geekId}"
    # ######## works with vers1

    dateAdded = DateTime.now
    yearAdjusted = dateAdded.year * 1000
    @scrape_date = yearAdjusted + DateTime.now.yday
    # puts date_adjusted
    @user_id = session[:user_id] ###dont need user_id for entering game entries. her for posterity
 

      def add_game
          HTTParty.post("http://localhost:9292/games/", body: {name: @name, geekId: @geekId, image: @image, scrape_date: @scrape_date, weight: @weight, playtime: @playtime, description: @description, designer: @designer})
            # puts "#{@name}, #{@boardgamemechanic}, #{@boardgamecategory}"
      end 
    add_game()
  end ###### END OF addSingleGame()

if respP[:items][:item].class == Hash
  addSingleGame(respP[:items][:item])
elsif respP[:items][:item].class == Array
  # puts respP[:items][:item].class
  respP[:items][:item].each do |var|
    addSingleGame(var)  
  end
end

# puts "DEX this is a single search: #{respP[:items][:item].class}"
# addSingleGame(respP)

    # puts "Trying to GET games"
    # get_games()
    puts "====================FINISH=================="
  redirect to('/../games')
end
########################
##################################


###Retriev single game id
  # get '/:id/?' do |id|
  #   game = Game.find(id)   
  #   if game 
  #      # {status: "Okay", message: "found a game #{params}"}.to_json
  #      game.to_json
  #     else
  #      {status: "ERROR", message: "Could not UPDATE game"}.to_json
  #     end    
  # end
#UPDATE game entry
  patch '/:id/?' do |id|
    game = Game.find(id)   
    if game 
        game.update name: params["name"] || game["name"], theme: params["theme"] || game["theme"], category: params["category"] || game["category"]
        {status: "Okay", message: "Game UPDATED"}.to_json
      else
        {status: "ERROR", message: "Could not UPDATE game"}.to_json
      end    
  end
#DELETE single entry
  delete '/:id/?' do |id|
    game = Game.find(id)   
    if game 
        game.destroy
        {status: "Okay", message: "Game DESTROYED"}.to_json
      else
        {status: "ERROR", message: "Could not DELETE game"}.to_json
      end  
  end
# DISPLAY ALL GAMES
  get '/?' do
    games = Game.all    
     if games
        @games_all = games
        erb :inventory    
      else
        {status: "ERROR", message: "Could not FIND ALL games"}.to_json    
      end
  end
# CREATE GAME NEW ENTRY in my DB
  post '/?' do
  
  #########new create new entry code below. avoids redundancy by checking or existing geekik in mydb 1st
  Game.where(geek_id: params["geekId"]).first_or_create do |game|
    game.name = params["name"]
    puts params["name"]
    game.geek_id = params["geekId"]
    game.img_src = params["image"]
    game.scrape_date = params["scrape_date"]
    game.weight = params["weight"]
    game.playtime = params["playtime"]
    game.description = params["description"]
    game.designer = params["designer"]
  end
end
  ######old create new game entry code below. removed 
  #   game = Game.create name: params["name"], geek_id: params["geekId"], img_src: params["image"], scrape_date: params["scrape_date"], weight: params["weight"], playtime: params["playtime"], description: params["description"], designer: params["designer"]
  #   if game
  #     {status: "ok", message: "#{game.name} was created"}.to_json      
  #   else
  #     {status: "error", message: "COULD NOT CREATE ENTRY"}.to_json
  #   end    
  # end
end 
