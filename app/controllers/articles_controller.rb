class ArticlesController < ApplicationController
  before_action :require_login, except: [:index, :show]
  before_action :set_article, only: [:show, :edit, :update, :destroy]

  def index
    @articles = if params[:q].present?
      # Redis for search results
      CacheStore.redis_fetch("search:#{Digest::MD5.hexdigest(params[:q])}", expires_in: 300) do
        begin
          Article.search_articles(params[:q]).to_a
        rescue => e
          Rails.logger.error "Search failed: #{e.message}"
          Article.cached_published  # Fallback to cached published articles
        end
      end
    else
      # Memcached for published articles list
      Article.cached_published
    end
  end

  def show
    # @article is already set by set_article using cached_find
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)

    if @article.save
      redirect_to @article, notice: "Article created successfully."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @article.update(article_params)
      redirect_to @article, notice: "Article updated successfully."
    else
      render :edit
    end
  end

  def destroy
    @article.destroy
    redirect_to root_path, notice: "Article deleted."
  end

  private

  def set_article
    @article = Article.cached_find(params[:id])
  end

  def article_params
    params.require(:article).permit(:title, :body, :status)
  end
end
