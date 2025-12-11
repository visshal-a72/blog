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

  after_create_commit  { KafkaPublisher.publish('blog.articles', 'created', kafka_payload) }
  after_update_commit  { KafkaPublisher.publish('blog.articles', 'updated', kafka_payload) }
  after_destroy_commit { KafkaPublisher.publish('blog.articles', 'deleted', { id: id }) }

  def self.search_articles(query)
    return all if query.blank?

    # Parse query language
    parsed = parse_query(query)
    search_text = parsed[:text]
    status_filter = parsed[:status]

    search_definition = {
      query: {
        bool: {
          filter: []
        }
      }
    }

    # Add text search if present
    if search_text.present?
      search_definition[:query][:bool][:must] = {
        multi_match: {
          query: search_text,
          fields: ['title^3', 'body'],
          fuzziness: 'AUTO'
        }
      }
    else
      search_definition[:query][:bool][:must] = { match_all: {} }
    end

    # Add status filter
    if status_filter.present?
      search_definition[:query][:bool][:filter] << { term: { status: status_filter } }
    else
      search_definition[:query][:bool][:filter] << { term: { status: 'public' } }
    end

    __elasticsearch__.search(search_definition).records
  end

  private

  # Parse query syntax: "status:public rails tutorial" => { status: 'public', text: 'rails tutorial' }
  def self.parse_query(query)
    status = nil
    text_parts = []

    query.split(/\s+/).each do |token|
      if token.match?(/^status:(\w+)$/i)
        status = token.split(':').last.downcase
      else
        text_parts << token
      end
    end

    { status: status, text: text_parts.join(' ') }
  end

  def kafka_payload
    { id: id, title: title, status: status }
  end

  def invalidate_cache
    CacheStore.redis_delete("article:#{id}")
    CacheStore.memcached_delete("articles:published")
    CacheStore.redis_delete("article:public_count")
  end
end
