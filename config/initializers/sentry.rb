# frozen_string_literal: true

unless Rails.env.development?
  Sentry.init do |config|
    config.dsn = "https://9faa29bb8a3b656d7ad1711203d00307@o4506295251173376.ingest.sentry.io/4506765652656128"
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Set traces_sample_rate to 1.0 to capture 100%
    # of transactions for performance monitoring.
    # We recommend adjusting this value in production.
    config.traces_sample_rate = 0.2
  end
end
