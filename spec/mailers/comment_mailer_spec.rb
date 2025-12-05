require 'rails_helper'

RSpec.describe CommentMailer, type: :mailer do
  let(:article) { create(:article, title: "Test Article") }
  let(:comment) { create(:comment, article: article, commenter: "John", body: "Nice post!") }
  let(:mail) { described_class.new_comment_notification(article, comment) }

  # ============================================
  # EMAIL HEADERS
  # ============================================

  describe 'headers' do
    it 'sends to the correct recipient' do
      expect(mail.to).to eq(['visshal.anandhkumar@freshworks.com'])
    end

    it 'sends from the correct address' do
      expect(mail.from).to eq(['visshal.anandhkumar@freshworks.com'])
    end

    it 'has the correct subject' do
      expect(mail.subject).to eq("New comment on: Test Article")
    end
  end

  # ============================================
  # EMAIL BODY
  # ============================================

  describe 'body' do
    it 'contains the article title' do
      expect(mail.body.encoded).to include("Test Article")
    end

    it 'contains the commenter name' do
      expect(mail.body.encoded).to include("John")
    end

    it 'contains the comment body' do
      expect(mail.body.encoded).to include("Nice post!")
    end

    it 'contains the article URL' do
      expect(mail.body.encoded).to include("articles/#{article.id}")
    end
  end

  # ============================================
  # DELIVERY
  # ============================================

  describe 'delivery' do
    it 'delivers the email' do
      expect { mail.deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end
end
