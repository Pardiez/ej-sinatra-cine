require 'rubygems'
require 'sinatra'

SITE_TITLE = "CineTicket"
SITE_DESCRIPTION = "Tu entrada de cine online"

Ticket = Struct.new(:id, :name, :phone, :email, :film)
Film = Struct.new(:id, :title, :price)

tickets = []
films = [
  Film.new(1, 'Peli1', 2),
  Film.new(2, 'Peli2', 3.5)
]


def max_id_of(array)
  return 0 if array.size == 0
  array.max_by(&:id).id
end

get '/' do
  @title = 'Inicio'
  erb :home
end

get '/buy/?' do
  @films = films
  @title = 'Compra'
  erb :buy
end

post '/buy/?' do
  @film = films.find { |f| f.id == params[:film].to_i }
  id = max_id_of(tickets) + 1
  @ticket = Ticket.new(id, params[:name], params[:phone], params[:email], @film)
  tickets << @ticket
  redirect '/ticket/' + id.to_s
end

get '/ticket/:id/?' do
  @ticket = tickets.find { |t| t.id == params[:id].to_i }
  erb :ticket
end

after do
  tickets.each{|t| p t.id}
end