require 'rubygems'
require 'sinatra'

SITE_TITLE = "CineTicket"
SITE_DESCRIPTION = "Tu entrada de cine online"

FILMS = [
  [1, 'Peli1', 2],
  [2, 'Peli2', 3.5]
]

tickets = []

get '/' do
  @title = 'Inicio'
  @tickets = tickets
  erb :home
end

get '/buy/?' do
  @films = FILMS
  @title = 'Compra'
  erb :buy
end

post '/buy/?' do
  tickets << [params[:name], params[:phone], params[:email], params[:film] ]
  redirect '/'
end

after do
  tickets.each{|ticket| p ticket.join(' | ')}
end