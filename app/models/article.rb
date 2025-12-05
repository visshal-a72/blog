class Article < ApplicationRecord
  include Visible
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks  # Auto-sync to ES on save/delete

  has_many :comments, dependent: :destroy

  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 10 }

  def self.search_articles(query)
    return all if query.blank?
    
    __elasticsearch__.search(query).records
  end
end
