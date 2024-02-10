# frozen_string_literal: true

require 'securerandom'
require 'aws-sdk-acm'
require 'dotenv'
Dotenv.load

class AcmIntegration
  def self.request_certificate
    response = acm_client.request_certificate(
      domain_name: 'viasulmt.com.br',
      validation_method: 'DNS',
      subject_alternative_names: ['*.viasulmt.com.br'],
      idempotency_token: SecureRandom.hex(10)
    )

    puts response.certificate_arn
  end

  def self.list_certificates
    response = acm_client.list_certificates
    response.certificate_summary_list
  rescue Aws::ACM::Errors::ServiceError => e
    puts "Error fetching certificate details: #{e}"
  end

  def self.specified_domain_certificate(domain)
    acm_certificates = list_certificates
    acm_certificates.flat_map do |certificate|
      validations_for_certificate(certificate, domain)
    end
  end

  private

  def self.acm_client
    @acm_client ||= Aws::ACM::Client.new(region: ENV.fetch('AWS_REGION', nil))
  end

  def self.validations_for_certificate(certificate, specified_domain)
    detailed_info = acm_client.describe_certificate(certificate_arn: certificate.certificate_arn)
    validation_options = detailed_info.certificate.domain_validation_options
    validation_options.filter_map do |validation|
      validation_data_for(validation, specified_domain)
    end.compact
  end

  def self.validation_data_for(validation, specified_domain)
    return unless domain_matches?(validation, specified_domain)
    return unless validation.validation_method == 'DNS' && validation.resource_record

    {
      domain_name: validation.domain_name,
      name_cname: validation.resource_record.name,
      value: validation.resource_record.value
    }
  end

  def self.domain_matches?(validation, domain)
    validation.domain_name == domain || validation.domain_name.include?(domain)
  end

  private_class_method :acm_client, :validations_for_certificate, :validation_data_for, :domain_matches?
end

# result = AcmIntegration.list_certificates
# p "resultado: #{result}"

puts AcmIntegration.specified_domain_certificate('viasulmt.com.br')
