class KafkaPublisher
  def self.publish(topic, event_type, data)
    message = {
      event: event_type,
      data: data,
      timestamp: Time.current.iso8601
    }.to_json

    KAFKA_PRODUCER.produce(message, topic: topic)
    Rails.logger.info "[KAFKA] Published #{event_type} to #{topic}"
    true
  rescue Kafka::Error => e
    Rails.logger.error "[KAFKA ERROR] #{e.message}"
    false
  end
end