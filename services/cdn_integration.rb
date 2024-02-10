# frozen_string_literal: true

require 'securerandom'
require 'aws-sdk-cloudfront'
require 'dotenv'
Dotenv.load

class CloudFrontIntegration
  def self.list_distributions
    response = cdn_client.list_distributions

    response.distribution_list.items
  end

  private

  def self.cdn_client
    @cdn_client ||= Aws::CloudFront::Client.new(region: ENV.fetch('AWS_REGION', nil))
  end

  private_class_method :cdn_client
end

result = CloudFrontIntegration.list_distributions
p result
