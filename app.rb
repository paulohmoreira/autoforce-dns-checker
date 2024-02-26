# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require_relative 'services/acm_integration'
require_relative 'services/dns_service'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    set :erb, layout: :layout
  end

  get '/' do
    erb :index
  end

  get '/show' do
    @domain = session[:domain]
    @a_root, @cname_www, @a_www = DnsService.get_dns(@domain)

    @root_domain = DnsService.extract_root_domain(@domain)
    @acm_certificate = AcmIntegration.specified_domain_certificate(@root_domain)

    erb :show
  end

  post '/result' do
    session[:domain] = params[:domain]

    redirect to('/show')
  end
end
