require 'sinatra'

set :views, settings.root + '/app/views'

get '/' do
  erb :index
end