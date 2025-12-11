module Visible
  extend ActiveSupport::Concern

  VALID_STATUSES = ['public', 'private', 'archived']

  included do
    validates :status, inclusion: { in: VALID_STATUSES }
  end

  class_methods do
    def public_count
      CacheStore.redis_fetch("#{name.downcase}:public_count", expires_in: 300) do
        where(status: 'public').count
      end
    end
  end

  def archived?
    status == 'archived'
  end
end
  