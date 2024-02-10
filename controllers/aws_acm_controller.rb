# frozen_string_literal: true

require 'securerandom'
require 'aws-sdk-acm'
require 'dotenv'
Dotenv.load

class AcmIntegration
  def self.request_certificate
    acm = Aws::ACM::Client.new(region: ENV.fetch('AWS_REGION', nil))
  
    response = acm.request_certificate(
      domain_name: 'viasulmt.com.br',
      validation_method: 'DNS',
      subject_alternative_names: ['*.viasulmt.com.br'],
      idempotency_token: SecureRandom.hex(10)
    )
  
    puts response.certificate_arn
  end

  def self.list_certificates # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
    acm = Aws::ACM::Client.new(region: ENV.fetch('AWS_REGION', nil))
    specified_domain = 'viasulmt.com.br'

    begin
      response = acm.list_certificates

      response.certificate_summary_list.each do |certificate|
        detailed_info = acm.describe_certificate(certificate_arn: certificate.certificate_arn)
        validation_options = detailed_info.certificate.domain_validation_options

        validation_options.each do |validation|
          next unless validation.domain_name == specified_domain || validation.domain_name.include?(specified_domain)
          next unless validation.validation_method == 'DNS' && validation.resource_record

          puts "Resource Record Name (CNAME) for #{specified_domain}: #{validation.resource_record.name}"
          puts "Resource Record Value for #{specified_domain}: #{validation.resource_record.value}"
          break
        end
      end
    rescue Aws::ACM::Errors::ServiceError => e
      puts "Error fetching certificate details: #{e}"
    end
  end
end

result = AcmIntegration.list_certificates
p result
