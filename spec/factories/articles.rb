FactoryBot.define do
    factory :article do
      title { "How to Learn Rails" }
      body { "This is a comprehensive guide to learning Rails framework." }
      status { "public" }
  
      trait :draft do
        status { "private" }
        title { "Work in Progress" }
      end
  
      trait :invalid do
        title { nil }
        body { nil }
      end
    end
end


