require 'kafka'

KAFKA_CLIENT = Kafka.new(
  seed_brokers: ['localhost:9092'],
  client_id: 'blog-app',
  logger: Rails.logger
)

KAFKA_PRODUCER = KAFKA_CLIENT.async_producer(
  delivery_interval: 10,
  delivery_threshold: 100
)

at_exit { KAFKA_PRODUCER.shutdown }
