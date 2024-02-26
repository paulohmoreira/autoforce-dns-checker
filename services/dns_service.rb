# frozen_string_literal: true

require 'resolv'

class DnsService
  def self.get_dns(domain)
    root_domain = extract_root_domain(domain)
    a_root = fetch_a_records(root_domain)
    cname_www = fetch_cname_records("www.#{root_domain}")
    a_www = fetch_a_records("www.#{root_domain}")

    [a_root, cname_www, a_www]
  end

  def self.extract_root_domain(domain)
    domain.gsub(/^www\./, '')
  end

  def self.fetch_a_records(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::A).map { |record| record.address.to_s }
    end
  end

  def self.fetch_cname_records(domain)
    Resolv::DNS.open do |dns|
      dns.getresources(domain, Resolv::DNS::Resource::IN::CNAME).map { |record| record.name.to_s }
    end
  end
end
