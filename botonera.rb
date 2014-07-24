require 'sinatra/base'
class Botonera < Sinatra::Base
  get "/" do
    haml :index
  end
end
