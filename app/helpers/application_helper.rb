# frozen_string_literal: true

module ApplicationHelper
  def flash_key_to_color(key)
    case key.to_sym
    when :notice
      "blue"
    when :alert
      "red"
    when :success
      "green"
    end
  end
end
