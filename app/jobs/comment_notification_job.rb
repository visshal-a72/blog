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

    return unless article && comment

    CommentMailer.new_comment_notification(article, comment).deliver_now
  end
end
