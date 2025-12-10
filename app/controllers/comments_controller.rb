class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_article
  
  def create
    if @article.archived?
      redirect_to @article, alert: "Cannot comment on archived articles"
      return
    end
    
    @comment = @article.comments.create(comment_params)

    if @comment.persisted?
      # Manual enqueue with Sidekiq::Client
      CommentNotificationJob.enqueue(@article.id, @comment.id)
    end

    redirect_to article_path(@article)
  end

  def destroy
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article), notice: "Comment deleted."
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:commenter, :body, :status)
  end
end
