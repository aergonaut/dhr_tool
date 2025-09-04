# frozen_string_literal: true

class LinkUnfurlError < StandardError
  attr_reader :url, :error_type

  def initialize(message, url: nil, error_type: nil)
    super(message)
    @url = url
    @error_type = error_type
  end
end
