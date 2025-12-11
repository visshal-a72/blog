class CommentsController < ApplicationController
  before_action :require_login
  before_action :set_article
  
  def create
    if @article.archived?
      redirect_to @article, alert: "Cannot comment on archived articles"
      return
    end
    
    @comment = @article.comments.build(comment_params)

    if @comment.save
      begin
        CommentNotificationJob.enqueue(@article.id, @comment.id)
      rescue Redis::CannotConnectError, Sidekiq::Client::Error => e
        Rails.logger.error "Failed to enqueue notification job: #{e.message}"
        # Comment was saved, just log the notification failure
      end
      redirect_to article_path(@article), notice: "Comment added."
    else
      redirect_to article_path(@article), alert: "Failed to add comment: #{@comment.errors.full_messages.join(', ')}"
    end
  end

  def destroy
    @comment = @article.comments.find(params[:id])
    
    if @comment.destroy
      redirect_to article_path(@article), notice: "Comment deleted."
    else
      redirect_to article_path(@article), alert: "Failed to delete comment."
    end
  end

  private

  def set_article
    @article = Article.find(params[:article_id])
  end

  def comment_params
    params.require(:comment).permit(:commenter, :body, :status)
  end
end
