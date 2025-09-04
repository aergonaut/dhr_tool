# frozen_string_literal: true

require "timeout"

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
    agent = configure_mechanize_agent

    agent.cookie_jar.add("accepted_tos", "20241119")

    page = fetch_page_with_retry(agent, url)

    if adult_content_warning?(page)
      unfurl_page_with_content_warning(page)
    else
      unfurl_page_without_content_warning(page)
    end
  end

  private

  def configure_mechanize_agent
    agent = Mechanize.new

    # Configure user agent to appear as a regular browser
    agent.user_agent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"

    # Set reasonable timeouts
    agent.open_timeout = 10
    agent.read_timeout = 30

    # Enable gzip compression
    agent.gzip_enabled = true

    # Follow redirects
    agent.redirect_ok = true

    # SSL configuration
    agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    agent.agent.http.ca_file = nil
    agent.agent.http.ca_path = nil

    agent
  end

  def fetch_page_with_retry(agent, url, max_retries: 3)
    retries = 0

    begin
      agent.get(url)
    rescue Mechanize::ResponseCodeError => e
      Rails.logger.error("HTTP Error #{e.response_code} for URL: #{url} - #{e.message}")

      case e.response_code.to_i
      when 429, 503, 525, 520, 521, 522, 523, 524
        # Rate limiting or server errors - retry with backoff
        if retries < max_retries
          retries += 1
          sleep_time = 2**retries
          Rails.logger.info("Retrying URL #{url} in #{sleep_time} seconds (attempt #{retries}/#{max_retries})")
          sleep(sleep_time)
          retry
        else
          raise LinkUnfurlError.new(
            "Server temporarily unavailable (#{e.response_code})",
            url: url,
            error_type: :server_error,
          )
        end
      when 403, 406
        # Forbidden or Not Acceptable - likely bot detection
        raise LinkUnfurlError.new("Access denied - content may be restricted", url: url, error_type: :access_denied)
      when 404
        # Not found
        raise LinkUnfurlError.new("Content not found", url: url, error_type: :not_found)
      else
        # Other HTTP errors
        raise LinkUnfurlError.new("Unable to access content (#{e.response_code})", url: url, error_type: :http_error)
      end
    rescue Timeout::Error => e
      Rails.logger.error("Timeout error for URL: #{url} - #{e.message}")

      if retries < max_retries
        retries += 1
        sleep_time = 2**retries
        Rails.logger.info("Retrying URL #{url} in #{sleep_time} seconds due to timeout (attempt #{retries}/#{max_retries})")
        sleep(sleep_time)
        retry
      else
        raise LinkUnfurlError.new("Request timed out", url: url, error_type: :timeout)
      end
    rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
      Rails.logger.error("Network error for URL: #{url} - #{e.message}")
      raise LinkUnfurlError.new("Network connection failed", url: url, error_type: :network_error)
    rescue OpenSSL::SSL::SSLError => e
      Rails.logger.error("SSL error for URL: #{url} - #{e.message}")

      if retries < max_retries
        retries += 1
        Rails.logger.info("Retrying URL #{url} with relaxed SSL verification (attempt #{retries}/#{max_retries})")

        # Try with relaxed SSL verification on retry
        agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        sleep(2)
        retry
      else
        raise LinkUnfurlError.new("SSL connection failed", url: url, error_type: :ssl_error)
      end
    rescue StandardError => e
      Rails.logger.error("Unexpected error for URL: #{url} - #{e.class}: #{e.message}")
      raise LinkUnfurlError.new("An unexpected error occurred", url: url, error_type: :unknown)
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
