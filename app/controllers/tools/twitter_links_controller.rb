# frozen_string_literal: true

module Tools
  class TwitterLinksController < ApplicationController
    def index
      @twitter_link = TwitterLink.new
    end

    def create
      @twitter_link = TwitterLink.new(twitter_link_params)
      respond_to do |format|
        format.turbo_stream
      end
    end

    private

    def twitter_link_params
      params.require(:twitter_link).permit(:url, :kind)
    end
  end
end
