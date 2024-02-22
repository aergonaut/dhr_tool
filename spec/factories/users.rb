# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    trait :confirmed do
      confirmed_at { Time.now.utc }
    end
  end
end
