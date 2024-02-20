# frozen_string_literal: true

module ApplicationHelper
  def flash_key_color(key)
    case key.to_sym
    when :notice
      "text-blue-800 bg-blue-50"
    when :alert
      "text-red-800 bg-red-50"
    when :success
      "text-green-800 bg-green-50"
    end
  end
end
