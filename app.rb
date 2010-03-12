begin
  require File.expand_path('../.bundle/environment', __FILE__)
rescue LoadError
  require "rubygems"
  require "bundler"
  Bundler.setup
end
Bundler.require

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
    @result = Bridge::Score.new(:contract => params['contract'], :vulnerable => (params['vulnerable'] == '1' ? true : false), :tricks => params['tricks']).points
  else
    @errors = "All fields are required"
  end
  haml :home
end

post '/calculate_inline' do
  if valid?(params)
    attrs = params['inline'].split(',').each { |p| p.strip! }
    @result = Bridge::Score.new(:contract => attrs[0], :tricks => attrs[1], :vulnerable => (attrs.size == 3)).points
  else
    @errors = "All fields are required"
  end
  haml :home
end

post '/points' do
  if valid?(params)
    contracts = Bridge::Score.with_points(params[:points].to_i)
    if contracts.empty?
      @errors = "Not found contracts with given points"
    else
      @result = contracts.join("<br/>")
    end
  else
    @errors = "All fields are required"
  end
  haml :home
end