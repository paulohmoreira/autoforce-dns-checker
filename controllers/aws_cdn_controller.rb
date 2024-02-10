# frozen_string_literal: true

require 'securerandom'
require 'aws-sdk-cloudfront'
require 'dotenv'
Dotenv.load

class CloudFrontIntegration
  def self.request_distributions
    cdn_client = Aws::CloudFront::Client.new(region: ENV.fetch('AWS_REGION', nil))

    response = cdn_client.list_distributions

    response.distribution_list.items
  end
end

result = CloudFrontIntegration.request_distributions
p result
