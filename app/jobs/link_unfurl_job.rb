# frozen_string_literal: true

class LinkUnfurlJob < ApplicationJob
  queue_as :default

  WORK_TITLE_SELECTOR = ".work h4.heading"
  WORDS_SELECTOR = "dd.words"
  CHAPTERS_SELECTOR = "dd.chapters"
  RATING_SELECTOR = "span.rating"

  def perform(url)
    link = Link.new(url: url)

    link.unfurl!

    {
      title: link.title,
      words: link.words,
      chapters: link.chapters,
      rating: link.rating,
    }
  rescue LinkUnfurlError => e
    Rails.logger.error("LinkUnfurlJob failed for URL: #{url} - #{e.class}: #{e.message}")

    {
      title: "Error: #{e.message}",
      words: "",
      chapters: "",
      rating: "",
    }
  rescue StandardError => e
    Rails.logger.error("LinkUnfurlJob failed for URL: #{url} - #{e.class}: #{e.message}")

    {
      title: "Error: An unexpected error occurred",
      words: "",
      chapters: "",
      rating: "",
    }
  end
end
