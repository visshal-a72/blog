require 'rails_helper'

RSpec.describe Article, type: :model do
  # ============================================
  # VALIDATION SPECS
  # ============================================
  
  describe 'validations' do
    # Using shoulda-matchers for one-liners
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:body) }
    it { should validate_length_of(:body).is_at_least(10) }
  end

  # ============================================
  # ASSOCIATION SPECS
  # ============================================

  describe 'associations' do
    it { should have_many(:comments).dependent(:destroy) }
  end

  # ============================================
  # BEHAVIOR SPECS
  # ============================================

  describe 'creating an article' do
    context 'with valid attributes' do
      it 'saves successfully' do
        article = build(:article)
        expect(article.save).to be true
      end
    end

    context 'with invalid attributes' do
      it 'fails without title' do
        article = build(:article, title: nil)
        expect(article.save).to be false
        expect(article.errors[:title]).to include("can't be blank")
      end

      it 'fails with short body' do
        article = build(:article, body: "Short")
        expect(article.save).to be false
        expect(article.errors[:body]).to include("is too short (minimum is 10 characters)")
      end
    end
  end

  describe 'destroying an article' do
    it 'destroys associated comments' do
      article = create(:article)
      create(:comment, article: article)
      
      expect { article.destroy }.to change(Comment, :count).by(-1)
    end
  end
end
