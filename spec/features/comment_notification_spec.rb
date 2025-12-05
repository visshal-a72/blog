require 'rails_helper'

RSpec.describe "Comment Notification Flow", type: :request do
  include ActiveJob::TestHelper

  describe "complete notification flow" do
    it "sends email when comment is created" do
      # Arrange
      article = create(:article, title: "My Awesome Article")
      
      # Act: Create comment - add status!
      perform_enqueued_jobs do
        post article_comments_path(article), params: {
          comment: { commenter: "Flow Tester", body: "This is great!", status: "public" }
        }
      end
      
      # Assert: Email was sent
      expect(ActionMailer::Base.deliveries.count).to eq(1)
      
      # Assert: Email content is correct
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eq("New comment on: My Awesome Article")
      expect(email.body.encoded).to include("Flow Tester")
      expect(email.body.encoded).to include("This is great!")
    end
  end
end
