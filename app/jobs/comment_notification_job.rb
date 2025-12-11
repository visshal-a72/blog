class CommentNotificationJob
  include Sidekiq::Worker
  
  sidekiq_options queue: 'mailers', retry: 3

  def self.enqueue(article_id, comment_id, delay: nil)
    payload = {
      'class' => self,
      'queue' => 'mailers',
      'args' => [article_id, comment_id]
    }
    payload['at'] = delay.to_f if delay
    
    Sidekiq::Client.push(payload)
  end

  def perform(article_id, comment_id)
    article = Article.find_by(id: article_id)
    comment = Comment.find_by(id: comment_id)

    unless article && comment
      Rails.logger.warn "CommentNotificationJob: Article #{article_id} or Comment #{comment_id} not found, skipping"
      return
    end

    begin
      CommentMailer.new_comment_notification(article, comment).deliver_now
      Rails.logger.info "CommentNotificationJob: Sent notification for comment #{comment_id}"
    rescue Net::SMTPError, Net::OpenTimeout => e
      Rails.logger.error "CommentNotificationJob: Mail delivery failed - #{e.message}"
      raise # Re-raise to trigger Sidekiq retry
    end
  end
end
