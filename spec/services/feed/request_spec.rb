require 'rails_helper'

describe Feed::Request do
  describe 'get' do
    let(:client) { Feed::Client.new }
    subject { described_class.new.send(:get, client, platform, metric) }

    context 'when no exception is raised' do
      let(:client_response) { double(get: response) }

      before do
        expect_any_instance_of(Feed::Client).to receive(:call).once.and_return(client_response)
      end

      context 'when response code is 200' do
        let(:facebook_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/facebook.json") }
        let(:twitter_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/twitter.json") }
        let(:instagram_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/instagram.json") }
        let(:data) do
          {
            facebook: facebook_response.map { |post| post['status'] },
            instagram: instagram_response.map { |post| post['picture'] },
            twitter: twitter_response.map { |tweet| tweet['tweet'] }
          }
        end
        let(:response) { double(code: 200, body: body.to_json) }

        context 'facebook platform' do
          let(:platform) { :facebook }
          let(:metric) { 'status' }
          let(:body) { facebook_response }

          it 'returns correct data in response' do
            expect(subject[:data]).to eq data[:facebook]
          end
        end

        context 'instagram platform' do
          let(:platform) { :instagram }
          let(:metric) { 'picture' }
          let(:body) { instagram_response }

          it 'returns correct data in response' do
            expect(subject[:data]).to eq data[:instagram]
          end
        end

        context 'twitter platform' do
          let(:platform) { :twitter }
          let(:metric) { 'tweet' }
          let(:body) { twitter_response }

          it 'returns correct data in response' do
            expect(subject[:data]).to eq data[:twitter]
          end
        end
      end

      context 'when response code is not 200' do
        let(:response) { double(code: 404) }
        let(:platform) { :facebook }
        let(:metric) { 'status' }

        it 'returns error message in response' do
          expect(subject[:error_message]).to eq 'Something went wrong, could not fetch records.'
        end
      end
    end

    context 'when Restclient raises an exception' do
      let(:client_response) { double(code: 500, body: 'I am trapped in a social media factory send help') }
      let(:platform) { :facebook }
      let(:metric) { 'status' }

      before do
        expect_any_instance_of(Feed::Client).to receive(:call).once.and_raise(RestClient::InternalServerError.new)
        expect_any_instance_of(RestClient::InternalServerError).to receive(:response).once.and_return(client_response)
      end

      it 'returns error message in response' do
        expect(subject[:error_message]).to eq 'I am trapped in a social media factory send help'
      end
    end
  end

  describe 'metric_data' do
    subject { described_class.new.send(:metric_data, response) }

    context 'when response has error_message' do
      let(:response) { { error_message: 'Something went wrong.' } }

      it 'returns error in correct format' do
        expect(subject).to match_array [{ error: 'Something went wrong.' }]
      end
    end

    context 'when response does not have error_message' do
      let(:response) { { data: %w[foo bar] } }

      it 'returns data' do
        expect(subject).to eq %w[foo bar]
      end
    end
  end
end
