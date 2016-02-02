require 'sinatra'
require 'sinatra/contrib'
require 'pony'
require 'hashids'

config_file 'config.yml'

configure :production do
    set "HASH_SALT", ENV['HASH_SALT']
    set "email_options", {
      :from => ENV['EMAIL_FROM'],
      :via => :smtp,
      :via_options => {
        :address => 'smtp.sendgrid.net',
        :port => '587',
        :domain => 'heroku.com',
        :user_name => ENV['SENDGRID_USERNAME'],
        :password => ENV['SENDGRID_PASSWORD'],
        :authentication => :plain,
        :enable_starttls_auto => true
      },
    }
end

configure :development do
    set "email_options", {
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => settings.EMAIL_USER,
        :password             => settings.EMAIL_PASS,
        :authentication       => :plain,
        :domain               => "localhost.localdomain"
      }
    }
end

SITE_TITLE = "CineTicket"
SITE_DESCRIPTION = "Tu entrada de cine online"
hashids = Hashids.new settings.HASH_SALT


class Tickets
  def initialize
    @tickets = []
  end

  def add(ticket)
    id = max_id + 1
    @tickets << ticket
    ticket.id = id
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
  attr_accessor :id

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

films.add(Film.new('Star Wars', 2))
films.add(Film.new('Mad Max', 3.5))

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
  film = films.get(params[:film])
  @ticket = Ticket.new(params[:name], params[:phone], params[:email], film)
  tickets.add(@ticket)
  hash = hashids.encode(tickets.max_id)
  @url = 'http://' + request.host + '/ticket/' + hash
  send_mail

  redirect '/ticket/' + hash
end

get '/ticket/:hash/?' do
  hash = params[:hash]
  id = hashids.decode(hash)[0].to_i
  @ticket = tickets.find { |t| t.id == id }
  erb :ticket
end

def send_mail
  Pony.options = settings.email_options
  Pony.mail :to => params[:email],
            :subject => 'Aqui tienes tu entrada de cine',
            :html_body => erb(:email_html, layout: false),
            :body => erb(:email, layout: false)
end

after do
  tickets.each{|t| p t.id}
end