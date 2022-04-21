class FeedsController < ApplicationController
  def index
    feed_response = Feed::Request.call

    if feed_response.success?
      render json: feed_response.data, status: :ok
    else
      render json: { errors: feed_response.errors }, status: :internal_server_error
    end
  end
end
