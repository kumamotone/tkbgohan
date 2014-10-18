#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-

require 'rubygems'
require 'twitter'
require 'tweetstream'

require 'net/https'
require 'oauth'
require 'json'
require 'pp'
require 'sparql/client'

REPNODEF = 1
REPRAMEN = 2
REPSUSHI = 3
REPWASHOKU = 4

class TkbGohan
  CONSUMER_KEY       = 'pqDGrK16Kbty5Dd4gamhcEka3'
  CONSUMER_SECRET    = '6OYuyyoWeLZs6gPGwAYbzZ2BYW0yz7qMqtjbItfsJBkE1rf8aG'
  ACCESS_TOKEN        = '2638738820-yaOqHAElDlVAl9vtFuWrZdBrBNoVHD1kil5DGFt'
  ACCESS_TOKEN_SECRET = 'Onel3CTVvFzcbryDrexDaifT3CE9lK1CRqONb37mWvBYc' 

  MY_SCREEN_NAME = "TKBGohanTest"
  BOT_USER_AGENT = "つくばご飯情報bot @#{MY_SCREEN_NAME}"
  
  # すべてのrestaurantを得るメソッド
  def getRestaurants()
    client = SPARQL::Client.new("http://localhost:8890/sparql/")
    
    q ="SELECT distinct ?s FROM <http://127.0.0.1:4567/>
        WHERE { ?s ?p ?o .
        FILTER regex(?s, \"restaurant\")
        } "
    
    results = client.query(q)
    a = []
    
    results.each do |solution|
      tmp = String.new("#{solution[:s]}")
      a.push(tmp)
     end
    return a
  end
   
  # すべてのmenuを得るメソッド
  def getMenus()
     client = SPARQL::Client.new("http://localhost:8890/sparql/")
     
    q ="SELECT distinct ?s FROM <http://127.0.0.1:4567/>
  WHERE {
  ?s ?p ?o .
  FILTER regex(?s, \"menu\")
  } "
    
     results = client.query(q)
    a = []
    
    results.each do |solution|
      tmp = String.new("#{solution[:s]}")
      a.push(tmp)
    end
     return a
   end
  
  # 指定したRestaurantのテキストを出力するメソッド
  
   def printRestaurantText(str, rFilename)
     client = SPARQL::Client.new("http://localhost:8890/sparql/")
     file = File.open(rFilename , "a")
     
     q ="SELECT * FROM <http://127.0.0.1:4567/>
  WHERE { <" + str + "> ?p ?o . }"
     
     results = client.query(q)
     
     results.each do |solution|
       s = String.new("#{solution[:p]}")
       case s
       when "http://127.0.0.1:4567/predicate#time" then
         file.write "営業時間:"
       when "http://127.0.0.1:4567/predicate#tenis" then 
         file.write "定休日:"
       end
       file.write "#{solution[:o]} "
     end
     file.write str + " "
     file.write "\n"
   end
   
  # 指定したMenuのテキストを出力するメソッド
   
   def printMenuText(str, mFilename)
     client = SPARQL::Client.new("http://localhost:8890/sparql/")
     file = File.open(mFilename , "a")
     
     q ="SELECT * FROM <http://127.0.0.1:4567/>
  WHERE { <" + str + "> ?p ?o . }"
     
     results = client.query(q)
     
     results.each do |solution|
       p = String.new("#{solution[:p]}")
       
       if p.include?("ismenuof") then
         o = String.new("#{solution[:o]}")
         q2 = "SELECT ?o FROM <http://127.0.0.1:4567/>
      WHERE { <"+o+"> ?p ?o .
      FILTER regex(?p, \"label\") } "
         results2 = client.query(q2)
        results2.each do |solution2|
           file.write "#{solution2[:o]} "
         end
       elsif p.include?("rdf-schema#price") then
         file.write "#{solution[:o]}" + "円 "
       elsif p.include?("janre") then         
         
      else 
         file.write "#{solution[:o]} "
       end
     end
     file.write str + " "
    file.write "\n"
   end
   
   def search_janre(category)
rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?restlabel where { ?s <http://www.w3.org/2004/02/skos/core#related>
              <http://ja.dbpedia.org/resource/Category:#{category}> .
                       ?x <http://purl.org/dc/terms/subject> ?s .
                       ?menuurl <http://purl.org/dc/terms/subject> ?x .
                       ?menuurl <http://127.0.0.1:4567/predicate#ismenuof> ?resturl.
                       ?resturl <http://www.w3.org/2000/01/rdf-schema#label> ?restlabel.
                       ?menuurl <http://www.w3.org/2000/01/rdf-schema#label> ?menulabel
                       }"

     results = myclient.query(q)
     results.each do |solution|
      tmp =String.new("#{solution[:restlabel]}")
      rs.push(tmp)
       # puts "pushed" + tmp
     end

    rtxt = ""     
     (rs.uniq).each do |r|
       rtxt = rtxt + " " + r 
     end
     return rtxt
   end

   def search_restaurant(subj)
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?y where { ?s <http://purl.org/dc/terms/subject> <http://ja.dbpedia.org/resource/" + subj  + "> .
         ?s <http://127.0.0.1:4567/predicate#ismenuof> ?x .
         ?x <http://www.w3.org/2000/01/rdf-schema#label> ?y }"

     puts q

     results = myclient.query(q)
     results.each do |solution|
       tmp = String.new("#{solution[:y]}")
       rs.push(tmp)
       puts "pushed" + tmp
     end
     rtxt = ""
     
     (rs.uniq).each do |r|
       rtxt = rtxt + " " + r 
     end
     return rtxt
   end

   def reply_judge(username,comments)
     puts "judge:" + username + ":" + comments
     rtxt = ""
     if username == "TKBGohanTest" then
       puts "UserName is TKBGohanTest. ret0"
       return nil
     elsif comments.include?("@TKBGohanTest") then
       if comments.include?("和食") then #和食はジャンル
         rtxt = search_janre("日本の食文化")
         str = "@" + username + " [ジャンル:和食の検索結果] "  + rtxt + " " + "http:\/\/127.0.0.1:4567\/search\/janre\/和食"
        puts str
         return str
       elsif comments.include?("ラーメン") then
         puts "ramendayo"
         rtxt = search_restaurant("ラーメン")
         str = "@" + username + " [料理:ラーメンの検索結果] "  + rtxt+ " " + "http:\/\/127.0.0.1:4567\/search\/ラーメン"
         return str
       elsif comments.include?("寿司") then
         rtxt = search_restaurant("寿司")
         str = "@" + username + " [料理:寿司の検索結果] "  + rtxt+ " " + "http:\/\/127.0.0.1:4567\/search\/寿司"

         return str
       elsif comments.include?("定食") then
         rtxt = search_restaurant("定食")
         str = "@" + username + " [料理:定食の検索結果] "  + rtxt+ " " + "http:\/\/127.0.0.1:4567\/search\/定食"
         return str
       end
       puts "Include @TKBGohanTest. But NoMatch. REPNODEF"
       return nil
     else
       puts "Not Reply. ret0"
       return nil
     end
   end
     
   def userStreamTest
     TweetStream.configure do |config|
       config.consumer_key       = CONSUMER_KEY
       config.consumer_secret    = CONSUMER_SECRET
       config.oauth_token        = ACCESS_TOKEN
       config.oauth_token_secret = ACCESS_TOKEN_SECRET
       config.auth_method        = :oauth
     end
     
     normalclient = Twitter::REST::Client.new do |config|
       config.consumer_key        = CONSUMER_KEY
       config.consumer_secret     = CONSUMER_SECRET
       config.access_token        = ACCESS_TOKEN
       config.access_token_secret = ACCESS_TOKEN_SECRET
     end

     streamclient = TweetStream::Client.new
     streamclient.userstream do |status|
       username = status.user.screen_name
       contents = status.text
       id = status.id
       
       str = reply_judge(username,contents)
       if str != nil then
         normalclient.update(str, :in_reply_to_status_id => id)
       end
     end
   end
   
   def tweet
    client = Twitter::REST::Client.new do |config|
  config.consumer_key       = CONSUMER_KEY
  config.consumer_secret    = CONSUMER_SECRET
  config.oauth_token        = ACCESS_TOKEN
  config.oauth_token_secret = ACCESS_TOKEN_SECRET
    end
     filename = 'menus.txt'
     linefilename = 'linefile'
     
     line = 0
     open("linefile"){ |linefile|
       line = linefile.gets.to_i()
       puts "line:" + line.to_s()
    }
    
     # 行数を数える
     endline = 0
     open(filename, "r"){ |file|
       while l = file.gets
         endline += 1
       end
     }
     puts "endline:" + endline.to_s()
     
    loop{
       t = Time.now
       puts t
       if t.sec%20 == 0
        puts "t.sec==0"
         # 最後まで読み込んだら最初に１行目に戻る
         
         if line >= endline
           line = 0
           open(linefilename, "w"){ |linefile|
             linefile.write line
           }
         end 
        
         #１行ずつ読み込みツイートを行う
         open(filename, "r") {|file|
           tw = file.readlines[line]
           /\/menu\/\d{3}/ =~ tw
           picname = "./pic" + $& + ".jpg"
           puts picname
          client.update_with_media(tw, File.open(picname))
           puts "line:" + line.to_s() +  " Tweeted."
           line += 1
           open(linefilename, "w"){ |linefile|
             linefile.write line
           }

         }
       end
      
       # sleepをしないとCPU負荷が高い
       sleep 1
     }
   end
  
  def makeTweets
    rs = getRestaurants()
    
    rFilename = "restaurants.txt"
    if File.exist?(rFilename) then 
      File.unlink rFilename
    end
    
    for r in rs do
      printRestaurantText(r, rFilename)
    end
    
    ms = getMenus()
    
    mFilename = "menus.txt"
    if File.exist?(mFilename) then 
      File.unlink mFilename
    end
    for m in ms do
      printMenuText(m,mFilename)
  end
    puts "Tweets has been successfully saved."
  end 
  
  case ARGV[0]
  when "-m" then
    TkbGohan.new.makeTweets
  when "-t" then
    TkbGohan.new.tweet
  when "-r" then
    TkbGohan.new.run
  when "-u" then
    TkbGohan.new.userStreamTest
  end
end
