FactoryBot.define do
    factory :user do
        name {'John'}
        email { Faker::Internet.unique.email }
        password {'43252462'}
    end
end