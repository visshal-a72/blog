class CommentMailer < ApplicationMailer
  default from: 'visshal.anandhkumar@freshworks.com'

  def new_comment_notification(article, comment)
    @article = article
    @comment = comment
    @url = article_url(@article)

    mail(
      to: 'visshal.anandhkumar@freshworks.com',  # Your email to receive notifications
      subject: "New comment on: #{@article.title}"
    )
  end
end
