# frozen_string_literal: true

require 'securerandom'
require 'aws-sdk-cloudfront'
require 'dotenv'
Dotenv.load

class CloudFrontIntegration
  def self.find_distribution_by_certificate_arn(arn)
    distribution_list = list_distributions
    distribution_list.each do |distribution|
      return distribution.domain_name if distribution.viewer_certificate.acm_certificate_arn == arn
    end
  end

  private

  def self.cdn_client
    @cdn_client ||= Aws::CloudFront::Client.new(region: ENV.fetch('AWS_REGION', nil))
  end

  def self.list_distributions # rubocop:disable Metrics/MethodLength
    distributions = []
    next_marker = nil

    loop do
      response = cdn_client.list_distributions(
        marker: next_marker
      )

      break unless response.distribution_list&.items

      distributions.concat(response.distribution_list.items)

      break unless response.distribution_list.is_truncated

      next_marker = response.distribution_list.next_marker
    end

    distributions
  end

  private_class_method :cdn_client, :list_distributions
end
