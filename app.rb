Bundler.require

configure do
  set :app_file, __FILE__
  set :haml, {:format => :html5}

  Compass.configuration do |config|
    config.project_path = Sinatra::Application.root
    config.sass_dir     = File.join("views", "stylesheets")
    config.images_dir = File.join("public", "images")
    config.http_images_path = "/images"
    config.http_path = "/"
    config.http_stylesheets_path = "/stylesheets"
  end
  Encoding.default_external = 'utf-8'
end

helpers do
  def valid?(attributes = {})
    attributes.values.all? { |p| !p.empty? }
  end

  def contract_match(data)
    data.match(Bridge::Score::REGEXP)
  end

  def render_suit(contract)
    if contract =~ /[SHCD]/
      contract.gsub("S","&spades;").gsub("C", "&clubs;").gsub("H", "<em class='red'>&hearts;</em>").gsub("D", "<em class='red'>&diams;</em>")
    else
      contract
    end
  end
end

get "/stylesheets/screen.css" do
  content_type "text/css"
  sass :"stylesheets/screen", Compass.sass_engine_options
end

get "/" do
  haml :home
end

get "/score/:score" do |input|
  @input = input.gsub(" ", "+") # plus sign is eaten
  score = @input.gsub(/(v)\Z/i, "")
  @vulnerable = $1.nil? ? false : true
  if @contract = contract_match(score.upcase)
    begin
      @points = Bridge::Score.new(:contract => @contract[:contract], :tricks => @contract[:result], :vulnerable => @vulnerable).points
    rescue ArgumentError => e
      @errors = e.message
    end
  else
    @errors = "Wrong input: #{@input}"
  end
  haml :score
end

get "/points/:result" do |input|
  @input = input
  if @input =~ /\A-?\d{2,4}\Z/
    @contracts = Bridge::Score.with_points(@input.to_i)
    @errors = "Contracts not found with: #{@input}" if @contracts.empty?
  else
    @errors = "Wrong input: #{@input}"
  end
  haml :points
end

post "/calculate" do
  if valid?(params)
    if score = contract_match(params[:contract].upcase)
      redirect "/score/" << score[:contract] << score[:result] << (params[:vulnerable].nil? ? "" : "v")
    else
      @errors = "Wrong input: #{params[:contract]}"
    end
  else
    @errors = "All fields are required"
  end
  haml :home
end

post "/points" do
  if valid?(params)
    if params[:points] =~ /\A-?\d{2,4}\Z/
      redirect "/points/" << params[:points]
    else
      @errors = "Wrong input: #{params[:points]}"
    end
  else
    @errors = "All fields are required"
  end
  haml :home
end
