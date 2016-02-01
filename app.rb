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

Ticket = Struct.new(:id, :name, :phone, :email, :film)
Film = Struct.new(:id, :title, :price)
hashids = Hashids.new settings.HASH_SALT

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
  hash = hashids.encode(id)
  @url = 'http://' + request.host + '/ticket/' + hash

  Pony.options = settings.email_options
  Pony.mail :to => params[:email],
            :subject => 'Aqui tienes tu entrada de cine',
            :html_body => erb(:email_html, layout: false),
            :body => erb(:email, layout: false)

  redirect '/ticket/' + hash
end

get '/ticket/:hash/?' do
  hash = params[:hash]
  id = hashids.decode(hash)[0].to_i
  @ticket = tickets.find { |t| t.id == id }
  erb :ticket
end

after do
  tickets.each{|t| p t.id}
end