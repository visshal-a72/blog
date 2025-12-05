class CommentNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(article_id, comment_id)
    article = Article.find_by(id: article_id)
    comment = Comment.find_by(id: comment_id)

    return unless article && comment

    CommentMailer.new_comment_notification(article, comment).deliver_now
  end
end
