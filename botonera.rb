require 'sinatra/base'
require 'bson'
require 'mongoid'
require 'carrierwave'
require 'carrierwave/mongoid'
require 'mini_magick'

Mongoid.load!("config/mongoid.yml")

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :grid_fs

  version :thumb do
    process :resize_to_fill => [90,50]
  end
end

class SoundUploader < CarrierWave::Uploader::Base
  storage :grid_fs
end

class Button
  include Mongoid::Document
  mount_uploader :image, ImageUploader, type: String
  mount_uploader :sound, SoundUploader, type: String
  field :title, type: String
end

class Botonera < Sinatra::Base
  get "/" do
    @buttons = Button.all
    haml :index
  end

  get "/new_button" do
    @button = Button.new
    haml :new_button
  end

  post '/button' do
    #sound = File.open('uploads/'+params[:sound], 'w') do |f|
    #  f.write([:sound][:tempfile].read)
    #end
    #image = File.open('uploads/'+params[:image], 'w') do |f|
    #  f.write([:image][:tempfile].read)
    #end
    @button = Button.new(params)
    @button.image = params[:image]
    @button.sound = params[:sound]
    puts params
    if @button.save
      redirect '/'
    else
      haml :new_button
    end
  end
end
