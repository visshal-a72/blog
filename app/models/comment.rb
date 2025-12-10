class Comment < ApplicationRecord
  include Visible
  belongs_to :article

  after_destroy :log_comment_deletion
  before_save :sanitize_body

  private

  def log_comment_deletion
    Rails.logger.info "Comment ##{id} was deleted from Article ##{article_id}"
  end

  def sanitize_body
    self.body = body.strip if body.present?
  end
end
