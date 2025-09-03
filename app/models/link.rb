# frozen_string_literal: true

class Link
  include ActiveModel::Model

  attr_accessor :url, :title, :words, :chapters, :rating

  ADULT_CONTENT_WARNING_SELECTOR = "//h2[text()[contains(.,'Adult Content Warning')]]"

  ADULT_WORK_TITLE_SELECTOR = ".work h4.heading"
  ADULT_WORDS_SELECTOR = "dd.words"
  ADULT_CHAPTERS_SELECTOR = "dd.chapters"
  ADULT_RATING_SELECTOR = "span.rating"

  WORK_TITLE_SELECTOR = "h2.title.heading"
  AUTHOR_SELECTOR = "a[rel=author]"
  WORDS_SELECTOR = "dd.words"
  CHAPTERS_SELECTOR = "dd.chapters"
  RATING_SELECTOR = "dd.rating"

  def unfurl!
    agent = Mechanize.new

    agent.cookie_jar.add("accepted_tos", "20241119")

    page = agent.get(url)

    if adult_content_warning?(page)
      unfurl_page_with_content_warning(page)
    else
      unfurl_page_without_content_warning(page)
    end
  end

  def adult_content_warning?(page)
    page.search(ADULT_CONTENT_WARNING_SELECTOR).any?
  end

  def unfurl_page_with_content_warning(page)
    @title = page.search(ADULT_WORK_TITLE_SELECTOR).inner_text.strip.tr("\n", " ").squish
    @words = page.search(ADULT_WORDS_SELECTOR).inner_text.strip
    @chapters = page.search(ADULT_CHAPTERS_SELECTOR).inner_text.strip
    @rating = page.search(ADULT_RATING_SELECTOR).inner_text.strip
    @rating = "Teen" if @rating == "Teen And Up Audiences"
  end

  def unfurl_page_without_content_warning(page)
    @title = page.search(WORK_TITLE_SELECTOR).inner_text.strip.tr("\n", " ").squish
    author = page.search(AUTHOR_SELECTOR).inner_text.strip
    @title = "#{@title} by #{author}"
    @words = page.search(WORDS_SELECTOR).inner_text.strip
    @chapters = page.search(CHAPTERS_SELECTOR).inner_text.strip
    @rating = page.search(RATING_SELECTOR).inner_text.strip
    @rating = "Teen" if @rating == "Teen And Up Audiences"
    @rating = @rating[0]
  end
end
