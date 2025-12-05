class CommentsController < ApplicationController
  http_basic_authenticate_with name: "dhh", password: "secret", only: :destroy
  
  def create
    @article = Article.find(params[:article_id])
    
    if @article.archived?
      redirect_to @article, alert: "Cannot comment on archived articles"
      return
    end
    
    @comment = @article.comments.create(comment_params)

    # Queue the email notification job
    if @comment.persisted?
      CommentNotificationJob.perform_later(@article.id, @comment.id)
    end

    redirect_to article_path(@article)
  end

  def destroy
    @article = Article.find(params[:article_id])
    @comment = @article.comments.find(params[:id])
    @comment.destroy
    redirect_to article_path(@article)
  end

  private
    def comment_params
      params.require(:comment).permit(:commenter, :body, :status)
    end
end
