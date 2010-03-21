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

  def contract_match(data)
    data.match(Bridge::Score::REGEXP)
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
    if score = contract_match(params[:contract].upcase)
      begin
        @result = Bridge::Score.new(:contract => score[:contract], :tricks => score[:result], :vulnerable => !params[:vulnerable].nil?).points
      rescue ArgumentError => e
        @errors = e.message
      end
    else
      @errors = "Wrong input: #{params[:contract]}"
    end
  else
    @errors = "All fields are required"
  end
  haml :home
end

post '/points' do
  if valid?(params)
    contracts = Bridge::Score.with_points(params[:points].to_i)
    if contracts.empty?
      @errors = "Contracts not found with: #{params[:points]}"
    else
      @result = contracts.join("<br/>")
    end
  else
    @errors = "All fields are required"
  end
  haml :home
end