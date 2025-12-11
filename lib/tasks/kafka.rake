namespace :kafka do
  desc "Consume article events"
  task consume: :environment do
    consumer = KAFKA_CLIENT.consumer(group_id: 'blog-consumer')
    consumer.subscribe('blog.articles')

    puts "Listening for events on blog.articles..."

    trap('INT') { consumer.stop }

    consumer.each_message do |message|
      event = JSON.parse(message.value)
      puts "[#{event['event']}] #{event['data']}"
    end
  end
end