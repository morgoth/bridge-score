begin
  # Require the preresolved locked set of gems.
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  # Fallback on doing the resolve at runtime.
  require "rubygems"
  require "bundler"
  Bundler.setup
end

#Bundler.require
%w(sinatra bridge haml compass).each { |dependency| require dependency }

configure do
  set :app_file, __FILE__
  set :haml, { :format => :html5 }

  Compass.configuration do |config|
    config.project_path = Sinatra::Application.root
    config.sass_dir     = File.join('views', 'stylesheets')
    config.images_dir = File.join('public', 'images')
    config.http_images_path = "/images"
    config.http_path = "/"
    config.http_stylesheets_path = "/stylesheets"
  end
end

helpers do
  def valid?(attributes = {})
    attributes.values.all? { |p| !p.empty? }
  end
end

get "/stylesheets/screen.css" do
  content_type 'text/css'
  sass :"stylesheets/screen", Compass.sass_engine_options
end

get '/' do
  haml :home
end

post '/calculate' do
  if valid?(params)
    @score = Bridge::Score.new(:contract => params['contract'], :vulnerable => (params['vulnerable'] == '1' ? true : false), :tricks => params['tricks'])
  else
    @errors = "All fields are required"
  end
  haml :home
end