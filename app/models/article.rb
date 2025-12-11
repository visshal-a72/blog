class Article < ApplicationRecord
  include Visible
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks  # Auto-sync to ES on save/delete

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  # Cache individual article
  def self.cached_find(id)
    CacheStore.redis_fetch("article:#{id}", expires_in: 900) do
      find(id)
    end
  end

  # Cache all published articles
  def self.cached_published
    CacheStore.memcached_fetch("articles:published", expires_in: 600) do
      where(status: 'public').to_a
    end
  end

  # Invalidate cache on update
  after_commit :invalidate_cache

  def self.search_articles(query)
    return all if query.blank?
    
    __elasticsearch__.search(query).records
  end

  private

  def invalidate_cache
    CacheStore.redis_delete("article:#{id}")
    CacheStore.memcached_delete("articles:published")
    CacheStore.redis_delete("article:public_count")  # Add this line
  end
end
