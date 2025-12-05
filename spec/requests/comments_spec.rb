require 'rails_helper'

RSpec.describe "Comments", type: :request do
  let(:article) { create(:article) }
  # Add status to the params
  let(:valid_params) { { comment: { commenter: "Test User", body: "Test comment", status: "public" } } }

  # ============================================
  # CREATE ACTION
  # ============================================

  describe "POST /articles/:article_id/comments" do
    it "creates a new comment" do
      expect {
        post article_comments_path(article), params: valid_params
      }.to change(Comment, :count).by(1)
    end

    it "redirects to article" do
      post article_comments_path(article), params: valid_params
      expect(response).to redirect_to(article_path(article))
    end

    it "enqueues notification job" do
      expect {
        post article_comments_path(article), params: valid_params
      }.to have_enqueued_job(CommentNotificationJob)
    end

    it "enqueues job with correct arguments" do
      post article_comments_path(article), params: valid_params
      new_comment = Comment.last
      
      expect(CommentNotificationJob).to have_been_enqueued.with(article.id, new_comment.id)
    end
  end

  # ============================================
  # DESTROY ACTION
  # ============================================

  describe "DELETE /articles/:article_id/comments/:id" do
    let!(:comment) { create(:comment, article: article) }
    let(:auth_headers) do
      { "HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
    end

    context "with valid credentials" do
      it "destroys the comment" do
        expect {
          delete article_comment_path(article, comment), headers: auth_headers
        }.to change(Comment, :count).by(-1)
      end

      it "redirects to article" do
        delete article_comment_path(article, comment), headers: auth_headers
        expect(response).to redirect_to(article_path(article))
      end
    end

    context "without credentials" do
      it "returns unauthorized" do
        delete article_comment_path(article, comment)
        expect(response).to have_http_status(:unauthorized)
      end

      it "does not destroy comment" do
        expect {
          delete article_comment_path(article, comment)
        }.not_to change(Comment, :count)
      end
    end
  end
end
