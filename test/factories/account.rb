# frozen_string_literal: true

FactoryBot.define do
  factory :account do
    balance { 1000.45 }
    user
  end
end
