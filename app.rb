require 'sinatra'
require 'pony'
require 'hashids'
require 'dotenv'
Dotenv.load

require './config'

SITE_TITLE = "CineTicket"
SITE_DESCRIPTION = "Tu entrada de cine online"

class Tickets
  def initialize
    @tickets = []
    @hashids = Hashids.new ENV['HASH_SALT']
  end

  def add(ticket)
    id = max_id + 1
    @tickets << ticket
    ticket.id = id
    ticket.hash = @hashids.encode(id)
  end

  def each(&block)
    @tickets.each(&block)
  end

  def find(&block)
    @tickets.find(&block)
  end

  def max_id
    return 0 if @tickets.size == 0
    @tickets.max_by(&:id).id
  end
end

class Films
  def initialize
    @films = []
  end

  def add(film)
    id = max_id + 1
    @films << film
    film.id = id
  end

  def each(&block)
    @films.each(&block)
  end

  def get(id)
    @films.find { |f| f.id == id.to_i }
  end

  def max_id
    return 0 if @films.size == 0
    @films.max_by(&:id).id
  end
end

tickets = Tickets.new
films = Films.new

class Ticket
  attr_reader :name, :phone, :email, :film
  attr_accessor :id, :hash

  def initialize(name, phone, email, film)
    @name, @phone, @email, @film = name, phone, email, film
  end
end

class Film
  attr_reader :title, :price
  attr_accessor :id

  def initialize(title, price)
    @title, @price = title, price
  end
end

class TicketManager
  def initialize(films, tickets)
    @films, @tickets = films, tickets
  end
  def buy(params)
    film = @films.get(params[:film])
    ticket = Ticket.new(params[:name], params[:phone], params[:email], film)
    @tickets.add(ticket)
    ticket
  end
end

films.add(Film.new('Star Wars', 2))
films.add(Film.new('Mad Max', 3.5))
ticketManager = TicketManager.new(films, tickets)

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
  @ticket = ticketManager.buy(params)
  @url = 'http://' + request.host + '/ticket/' + @ticket.hash
  send_mail

  redirect '/ticket/' + @ticket.hash
end

get '/ticket/:hash/?' do
  @ticket = tickets.find { |t| t.hash == params[:hash] }
  erb :ticket
end

def send_mail
  Pony.options = settings.email_options
  Pony.mail :to => params[:email],
            :subject => 'Aqui tienes tu entrada de cine',
            :html_body => erb(:email_html, layout: false),
            :body => erb(:email, layout: false)
end
