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
%w(sinatra bridge haml).each { |dependency| require dependency }

configure do
  set :app_file, __FILE__
  set :haml, { :format => :html5 }
end

get '/' do
  haml :home
end

post '/calculate' do
  @score = Bridge::Score.new(:contract => params['contract'], :declarer => params['declarer'], :vulnerable => params['vulnerable'], :tricks => params['tricks'].to_i)
  haml :home
end