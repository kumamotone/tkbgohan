# -*- coding: utf-8 -*-
require 'sparql/client'

# すべてのrestaurantを得るメソッド
def getRestaurants()
  client = SPARQL::Client.new("http://localhost:8890/sparql/")

  q ="SELECT distinct ?s FROM <http://tkbgohan.com/>
  WHERE {
  ?s ?p ?o .
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

  q ="SELECT distinct ?s FROM <http://tkbgohan.com/>
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

# 指定したRestaurantのテキストを得るメソッド

def getRestaurantText(str)
  client = SPARQL::Client.new("http://localhost:8890/sparql/")
  
  q ="SELECT * FROM <http://tkbgohan.com/>
  WHERE { <" + str + "> ?p ?o . }"

  results = client.query(q)
  
  results.each do |solution|
    s = String.new("#{solution[:p]}")
    case s
    when "http://tkbgohan.com/predicate#time" then
      print "営業時間:"
    when "http://tkbgohan.com/predicate#tenis" then 
      print "定休日:"
    end
    print "#{solution[:o]} "
  end
  puts ""
end

# 指定したMenuのテキストを得るメソッド

def getMenuText(str)
  client = SPARQL::Client.new("http://localhost:8890/sparql/")
  
  q ="SELECT * FROM <http://tkbgohan.com/>
  WHERE { <" + str + "> ?p ?o . }"

  results = client.query(q)
  
  results.each do |solution|
    p = String.new("#{solution[:p]}")
       
    if p.include?("ismenuof") then
      o = String.new("#{solution[:o]}")
      q2 = "SELECT ?o FROM <http://tkbgohan.com/>
      WHERE { <"+o+"> ?p ?o .
      FILTER regex(?p, \"label\") } "
      results2 = client.query(q2)
      results2.each do |solution2|
        print "#{solution2[:o]} "
      end
    elsif p.include?("rdf-schema#price") then
      print "#{solution[:o]}" + "円 "
    else 
      print "#{solution[:o]} "
    end
  end
  puts ""
end

# 営業していない時間の配列を得るメソッド

rs = getRestaurants()

for r in rs do
  getRestaurantText(r)
end

ms = getMenus()

for m in ms do
  getMenuText(m)
end
