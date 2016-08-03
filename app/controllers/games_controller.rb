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

#SEARCH
post '/search/?' do 
  if params["name"] == ""
    session[:message] = "Please enter a boardgame title to search"
    # erb :search_results
    redirect to('/../profile')
  end  

  puts params
  puts "Still going"

  searchname = params["name"]
  boardgamegeekApiSearch = "http://www.boardgamegeek.com/xmlapi2/search?query=#{searchname}&type=boardgame"
  puts "==============START====Attempting to serach by title" 
  response = HTTParty.get(boardgamegeekApiSearch)     

 respP = response.parsed_response
 respP = symbolize(respP)

 search_results = [] ###prepare search results
 
count = 0

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

#GEEK API
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
    # puts "Image URL: #{respP[:items][:item][:image].sub("//", "")}"
    @image = respP[:items][:item][:image].sub("//", "")
    # puts @name



    boardgamelinks = []
    boardgamecategory = []
    boardgamemechanic = []
    boardgamefamily = []
    boardgamedesigner = []



    respP[:items][:item][:link].each do |entry|
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

    puts "Categories: #{boardgamecategory}"
    puts "Mechanics: #{boardgamemechanic}"
    puts "Family: #{boardgamefamily}"
    puts "Designer: #{boardgamedesigner}"

    @boardgamecategory = boardgamecategory[0] || nil
    @boardgamemechanic = boardgamemechanic[0] || nil
    # @designer = boardgamedesigner.join(", ") || nil
    @designer = boardgamedesigner[0]|| nil
    @weight = respP[:items][:item][:statistics][:ratings][:averageweight][:value]
    # puts "averageweight: #{averageweight}"

    @playtime = respP[:items][:item][:playingtime][:value]
    # puts "Playtime: #{playingtime}"

    @description = respP[:items][:item][:description]
    # puts description

    @geekId = respP[:items][:item][:id]
    # puts "geekId: #{geekId}"
    # ######## works with vers1

    dateAdded = DateTime.now
    yearAdjusted = dateAdded.year * 1000
    @scrape_date = yearAdjusted + DateTime.now.yday
    # puts date_adjusted
    @user_id = session[:user_id]


     # return respP.to_json  

      def add_game
          HTTParty.post("http://localhost:9292/games/", body: {name: @name, geekId: @geekId, image: @image, scrape_date: @scrape_date, weight: @weight, playtime: @playtime, description: @description, user_id: @user_id, designer: @designer})
            # puts "#{@name}, #{@boardgamemechanic}, #{@boardgamecategory}"
      end 

      def get_games
        # HTTParty.get("http://localhost:9292/games/")
            # puts "#{@name}, #{@boardgamemechanic}, #{@boardgamecategory}"
      end 
      
    puts "Trying to add game"
    add_game()


    # puts "Trying to GET games"
    # get_games()
    puts "====================FINISH=================="
@games_liked = Game.where user_id: session[:user_id]
# erb :suggestions
redirect to('/../profile')
end



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
        games.to_json    
      else
        {status: "ERROR", message: "Could not FIND ALL games"}.to_json    
      end
  end
# CREATE NEW ENTRY
  post '/?' do
    game = Game.create name: params["name"], geek_id: params["geekId"], img_src: params["image"], scrape_date: params["scrape_date"], weight: params["weight"], playtime: params["playtime"], description: params["description"], user_id: params["user_id"], designer: params["designer"]
    if game
      {status: "ok", message: "#{game.name} was created"}.to_json      
    else
      {status: "error", message: "COULD NOT CREATE ENTRY"}.to_json
    end    
  end
###ALTERNATE MULTI-POST
# post '/?' do
#   games = [
#           {name: "deception",theme: "murder mystery",category: "social deduction"},
#           {name: "pandemic",theme: "bio disaster",category: "cooperative"},
#           {name: "27th passenger",theme: "hitmen",category: "logic deduction"},
#           {name: "alchemists",theme: "alchemy",category: "logic deduction"},
#           {name: "flick em up",theme: "wild west",category: "dexterity"}
#         ] 
#   games.each do |entry|
#     game = Game.create name: entry[:name], theme: entry[:theme], category: entry[:category]
#   end
# end







end 
