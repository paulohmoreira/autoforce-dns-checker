# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'resolv'
# require './helpers'
# require 'securerandom'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    # set :json_encoder, :to_json
    set :erb, layout: :layout
  end

  # before do
  #   headers['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
  #   headers['Access-Control-Allow-Origin'] = '*'
  #   headers['Access-Control-Allow-Headers'] = 'accept, authorization, origin'
  # end

  # options '*' do
  #   response.headers['Allow'] = 'HEAD,GET,PUT,DELETE,OPTIONS,POST'
  #   response.headers['Access-Control-Allow-Headers'] =
  #     'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
  # end

  def get_dns(domain)
    Resolv::DNS.open do |dns|
      root_domain = domain.gsub(/^www\./, '')

      a_records_root = dns.getresources root_domain, Resolv::DNS::Resource::IN::A
      a_root = a_records_root.map { |record| record.address.to_s }

      cname_records_www = dns.getresources "www.#{root_domain}", Resolv::DNS::Resource::IN::CNAME
      cname_www = cname_records_www.map { |record| record.name.to_s }

      a_records_www = dns.getresources "www.#{root_domain}", Resolv::DNS::Resource::IN::A
      a_www = a_records_www.map { |record| record.address.to_s }

      return a_root, cname_www, a_www
    end
  end

  get '/' do
    erb :index
  end

  get '/show' do
    @domain = session[:domain]
    @a_root, @cname_www, @a_www = get_dns(@domain)

    erb :show
  end

  post '/result' do
    session[:domain] = params[:domain]

    redirect to('/show')
  end
end
