FactoryBot.define do
  factory :comment do
    sequence(:commenter) { |n| "User #{n}" }
    body { "Great article! Very helpful." }
    status { "public" }
    association :article

    trait :private do
      status { "private" }
    end
  end
end
