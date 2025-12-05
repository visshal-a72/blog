require 'rails_helper'

RSpec.describe CommentNotificationJob, type: :job do
  let(:article) { create(:article) }
  let(:comment) { create(:comment, article: article) }

  # ============================================
  # QUEUE BEHAVIOR
  # ============================================

  describe 'queue' do
    it 'is enqueued in mailers queue' do
      expect {
        described_class.perform_later(article.id, comment.id)
      }.to have_enqueued_job.on_queue('mailers')
    end

    it 'is enqueued with correct arguments' do
      expect {
        described_class.perform_later(article.id, comment.id)
      }.to have_enqueued_job.with(article.id, comment.id)
    end
  end

  # ============================================
  # JOB EXECUTION
  # ============================================

  describe '#perform' do
    context 'with valid IDs' do
      it 'sends notification email' do
        expect {
          described_class.perform_now(article.id, comment.id)
        }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it 'sends email with correct subject' do
        described_class.perform_now(article.id, comment.id)
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to include(article.title)
      end
    end

    context 'with invalid article ID' do
      it 'does not send email' do
        expect {
          described_class.perform_now(999999, comment.id)
        }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it 'does not raise error' do
        expect {
          described_class.perform_now(999999, comment.id)
        }.not_to raise_error
      end
    end

    context 'with invalid comment ID' do
      it 'does not send email' do
        expect {
          described_class.perform_now(article.id, 999999)
        }.not_to change { ActionMailer::Base.deliveries.count }
      end

      it 'does not raise error' do
        expect {
          described_class.perform_now(article.id, 999999)
        }.not_to raise_error
      end
    end
  end
end