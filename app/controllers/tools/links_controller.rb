class Tools::LinksController < ApplicationController
  before_action :authenticate_user!

  def index
  end

  def create
    @link = Link.new(url: params[:url])
    @link.unfurl!
    respond_to do |format|
      format.turbo_stream
    end
  end
end
