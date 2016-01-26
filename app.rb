require 'rubygems'
require 'sinatra'

SITE_TITLE = "CineTicket"
SITE_DESCRIPTION = "Tu entrada de cine online"

get '/' do
  @title = 'Inicio'
  erb :home
end
