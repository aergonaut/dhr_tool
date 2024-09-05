# frozen_string_literal: true

require "uri"

class TwitterLink
  include ActiveModel::Model

  attr_reader :url
  attr_accessor :kind

  KINDS = [
    "Fic",
    "Ficlet",
    "Art",
    "Edit",
    "SocMed",
    "Art and ficlet",
    "Drabble",
    "Art and drabble",
  ]

  validates :url, presence: true
  validates :kind, presence: true, inclusion: { in: KINDS }

  def url=(value)
    @url = URI.parse(value) if value
  end

  def author
    url&.path&.split("/")&.second
  end
end
