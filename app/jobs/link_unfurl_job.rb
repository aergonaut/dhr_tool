# frozen_string_literal: true

class LinkUnfurlJob < ApplicationJob
  queue_as :default

  WORK_TITLE_SELECTOR = ".work h4.heading"
  WORDS_SELECTOR = "dd.words"
  CHAPTERS_SELECTOR = "dd.chapters"
  RATING_SELECTOR = "span.rating"

  def perform(url)
    agent = Mechanize.new
    page = agent.get(url)

    title = page.search(WORK_TITLE_SELECTOR).inner_text.strip.tr("\n", " ").squish
    words = page.search(WORDS_SELECTOR).inner_text.strip
    chapters = page.search(CHAPTERS_SELECTOR).inner_text.strip
    rating = page.search(RATING_SELECTOR).inner_text.strip

    {
      title:,
      words:,
      chapters:,
      rating:,
    }
  end
end
