# frozen_string_literal: true

require 'sinatra'
require 'sinatra/base'
require 'sinatra/reloader'
require 'resolv'
require_relative 'services/acm_integration'

class App < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  configure do
    enable :sessions
    set :erb, layout: :layout
  end

  def get_dns(domain)
    root_domain = extract_root_domain(domain)
    a_root = fetch_a_records(root_domain)
    cname_www = fetch_cname_records("www.#{root_domain}")
    a_www = fetch_a_records("www.#{root_domain}")

    [a_root, cname_www, a_www]
  end

  get '/' do
    erb :index
  end

  get '/show' do
    @domain = session[:domain]
    @a_root, @cname_www, @a_www = get_dns(@domain)

    @root_domain = extract_root_domain(@domain)
    @acm_certificate = AcmIntegration.specified_domain_certificate(@root_domain)

    erb :show
  end

  post '/result' do
    session[:domain] = params[:domain]

    redirect to('/show')
  end

  private

  def extract_root_domain(domain)
    domain.gsub(/^www\./, '')
  end

  def fetch_a_records(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::A).map { |record| record.address.to_s }
    end
  end

  def fetch_cname_records(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::CNAME).map { |record| record.name.to_s }
    end
  end
end
