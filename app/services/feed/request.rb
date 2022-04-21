module Feed
  class Request < ApplicationService
    SOCIAL_NETWORK_METRICS = {
      facebook: 'status',
      instagram: 'picture',
      twitter: 'tweet'
    }.freeze
    private_constant :SOCIAL_NETWORK_METRICS

    private

    def execute
      client = Client.new

      threads = []
      SOCIAL_NETWORK_METRICS.each do |platform, metric|
        threads << Thread.new do
          response = get(client, platform, metric)
          @data[platform] = metric_data(response)
        end
      end
      threads.each(&:join)
    end

    def get(client, platform, metric)
      response = client.call(platform).get
      if response.code == 200
        { data: JSON.parse(response.body).map { |res| res[metric] } }
      else
        { error_message: 'Something went wrong, could not fetch records.' }
      end
    rescue RestClient::InternalServerError => e
      { error_message: e.response&.body }
    rescue RestClient::Exceptions::Timeout
      { error_message: 'Connection timed out, could not fetch records.' }
    rescue RestClient::Exception
      { error_message: 'Something went wrong, could not fetch records.' }
    end

    def metric_data(response)
      return response[:data] if response[:error_message].blank?

      [{ error: response[:error_message] }]
    end
  end
end
