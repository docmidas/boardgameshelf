class CreateLikes < ActiveRecord::Migration
  def change
    create_table     :likes do |table|
      table.string   :name
      table.integer  :geek_id
      table.string   :img_src
      table.integer  :scrape_date
      table.float    :weight
      table.integer  :playtime
      table.text     :description
      table.integer  :user_id
    end  
  end
end
