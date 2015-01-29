# encoding: utf-8
require 'sinatra/base'
require 'bson'
require 'mongoid'
require 'carrierwave'
require 'carrierwave/mongoid'
require 'mini_magick'

configure :production do
  require 'newrelic_rpm'
end

Mongoid.load!("config/mongoid.yml")

CarrierWave.configure do |config|
  config.root = 'public/'
  config.fog_credentials = {
    :provider               => 'AWS',
    :region                 => 'us-west-2',
    :aws_access_key_id      =>  ENV['AWS_ACCESS_KEY_ID'],
    :aws_secret_access_key  =>  ENV['AWS_SECRET_ACCESS_KEY']
  }
  config.fog_directory  = ENV['AWS_BUCKET']
end

class ImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  storage :fog

  version :thumb do
    process :resize_to_fill => [90,50]
  end

  def extension_white_list
    %w(jpg jpeg gif png)
  end
end

class SoundUploader < CarrierWave::Uploader::Base
  storage :fog

  def extension_white_list
    %w(mp3)
  end
end

class Button
  include Mongoid::Document
  mount_uploader :image, ImageUploader, type: String
  mount_uploader :sound, SoundUploader, type: String
  field :title, type: String

  def size_valid?
    return true if image.file.size.to_f/(1000*1000) < 1.2 && sound.file.size.to_f/(1000*1000) < 1.2
    false
  end

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
    if @button.size_valid? && @button.save
      redirect '/'
    else
      @error = "Please select first an mp3 file then an Image file"
      haml :new_button
    end
  end
end
