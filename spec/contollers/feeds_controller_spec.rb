require 'rails_helper'

describe FeedsController, type: :controller do
  describe 'GET index' do
    before do
      expect(Feed::Request).to receive(:call).once.and_return(feed_response)
      get :index
    end

    context 'when result is success' do
      let(:facebook_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/facebook.json") }
      let(:twitter_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/twitter.json") }
      let(:instagram_response) { JSON.parse(File.read "#{Rails.root}/spec/fixtures/instagram.json") }
      let(:data) do
        {
          facebook: facebook_response.map { |post| post['status'] },
          instagram: instagram_response.map { |post| post['picture'] },
          twitter: twitter_response.map { |tweet| tweet['tweet'] }
        }.to_json
      end
      let(:feed_response) do
        double(data: data, success?: true)
      end

      it 'returns fetched data' do
        expect(response.body).to eq data
      end

      it 'responds with 200' do
        expect(response.code).to eq '200'
      end
    end

    context 'when result is failure' do
      let(:errors) { ['Something went wrong.'] }
      let(:feed_response) { double(errors: errors, success?: false) }

      it 'returns error' do
        expect(response.body).to eq ({ errors: errors }.to_json)
      end

      it 'responds with 500' do
        expect(response.code).to eq '500'
      end
    end
  end
end
