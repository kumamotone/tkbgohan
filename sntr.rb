# coding: utf-8
require 'sinatra'
require 'sinatra/reloader'
#require './twtest.rb'
require 'sparql/client'
set :environment, :production

def raise_restaurant(num)
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?p ?o where { <http://127.0.0.1:4567/restaurant/" + num + "> ?p ?o }"
     results = myclient.query(q)
     results.each do |solution|
      tmp = { "p" => String.new("#{solution[:p]}"),
      "o" => String.new("#{solution[:o]}") }  
      rs.push(tmp)
       # puts "pushed" + tmp
     end
     return rs
end

def raise_menu(num)
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?p ?o where { <http://127.0.0.1:4567/menu/" + num + "> ?p ?o }"
     results = myclient.query(q)
     results.each do |solution|
      tmp = { "p" => String.new("#{solution[:p]}"),
      "o" => String.new("#{solution[:o]}") }  
      rs.push(tmp)
       # puts "pushed" + tmp
     end
     return rs
end

def search_menu(subj)
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?menuurl ?menulabel ?resturl ?restlabel where { ?menuurl <http://purl.org/dc/terms/subject> <http://ja.dbpedia.org/resource/" + subj  + "> .
    ?menuurl <http://www.w3.org/2000/01/rdf-schema#label> ?menulabel .
    ?menuurl <http://127.0.0.1:4567/predicate#ismenuof> ?resturl .
    ?resturl <http://www.w3.org/2000/01/rdf-schema#label> ?restlabel}"
     results = myclient.query(q)
     results.each do |solution|
       tmp = {
      "menuurl" => String.new("#{solution[:menuurl]}"),
      "menulabel" => String.new("#{solution[:menulabel]}") ,  
      "resturl" => String.new("#{solution[:resturl]}"),
      "restlabel" => String.new("#{solution[:restlabel]}") }  
      rs.push(tmp)
       # puts "pushed" + tmp
     end
     return rs
end

def search_janre(subj)
     if subj.include?("和食") then
        janre = "日本の食文化"
     elsif subj.include?("中華") then
       janre = "中国の食文化"
     elsif subj.include?("洋食") then
       janre = "欧米の食文化"
     end
    
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?menuurl ?menulabel ?resturl ?restlabel where { ?s <http://www.w3.org/2004/02/skos/core#related>
              <http://ja.dbpedia.org/resource/Category:#{janre}> .
                       ?x <http://purl.org/dc/terms/subject> ?s .
                       ?menuurl <http://purl.org/dc/terms/subject> ?x .
                       ?menuurl <http://127.0.0.1:4567/predicate#ismenuof> ?resturl.
                       ?resturl <http://www.w3.org/2000/01/rdf-schema#label> ?restlabel.
                       ?menuurl <http://www.w3.org/2000/01/rdf-schema#label> ?menulabel
                       }"

     results = myclient.query(q)
     results.each do |solution|
       tmp = {
       
      "menuurl" => String.new("#{solution[:menuurl]}"),
      "resturl" => String.new("#{solution[:resturl]}"),
      "restlabel" => String.new("#{solution[:restlabel]}"),
      "menulabel" => String.new("#{solution[:menulabel]}")
       }
      rs.push(tmp)
       # puts "pushed" + tmp
     end
     return rs
end

def search_restaurant(subj)
     rs = []
     myclient = SPARQL::Client.new("http://localhost:8890/sparql/")
     q = "select distinct ?y where { ?s <http://purl.org/dc/terms/subject> <http://ja.dbpedia.org/resource/" + subj  + "> .
         ?s <http://127.0.0.1:4567/predicate#ismenuof> ?x .
         ?x <http://www.w3.org/2000/01/rdf-schema#label> ?y }"
     results = myclient.query(q)
     results.each do |solution|
       tmp = String.new("#{solution[:y]}")
       rs.push(tmp)
       puts "pushed" + tmp
     end
     return rs
   end

get '/' do
    erb :index
end

get '/search/janre/:name' do |name|
  @name = name
  @res = search_janre(name)
  erb :searchjanre
end

get '/search/:name' do |name|
  @name = name
  @res = search_menu(name)
  erb :search
end

get '/restaurant/:num' do |num|
  @res = raise_restaurant(num)
  erb :restaurant
end

get '/menu/:num' do |num|
  @res = raise_menu(num)
  erb :menu
end

