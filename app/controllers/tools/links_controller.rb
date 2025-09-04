# frozen_string_literal: true

module Tools
  class LinksController < ApplicationController
    before_action :authenticate_user!

    def index
    end

    def create
      @link = Link.new(url: params[:url])

      begin
        @link.unfurl!
        respond_to do |format|
          format.turbo_stream { render(:create) }
        end
      rescue LinkUnfurlError => e
        Rails.logger.error("Failed to unfurl link #{params[:url]}: #{e.class} - #{e.message}")
        flash.now[:alert] = "Unable to process link: #{e.message}"
        respond_to do |format|
          format.turbo_stream { render(:error) }
        end
      rescue StandardError => e
        Rails.logger.error("Unexpected error unfurling link #{params[:url]}: #{e.class} - #{e.message}")
        flash.now[:alert] = "An unexpected error occurred while processing the link"
        respond_to do |format|
          format.turbo_stream { render(:error) }
        end
      end
    end
  end
end
