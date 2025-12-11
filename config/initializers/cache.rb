REDIS_CLIENT = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1'),
  connect_timeout: 2,
  read_timeout: 1,
  write_timeout: 1
)

MEMCACHED_CLIENT = Dalli::Client.new(
  ENV.fetch('MEMCACHED_SERVERS', 'localhost:11211').split(','),
  {
    namespace: 'blog',
    compress: true,
    expires_in: 3600,
    failover: true
  }
)

# Helper module with common cache operations
module CacheStore
  class << self
    # Redis operations
    def redis
      REDIS_CLIENT
    end

    def redis_get(key)
      value = REDIS_CLIENT.get(key)
      if value
        Rails.logger.info "[REDIS HIT] Key: #{key}"
        Marshal.load(value)
      else
        Rails.logger.info "[REDIS MISS] Key: #{key}"
        nil
      end
    rescue Redis::BaseError => e
      Rails.logger.error "[REDIS ERROR] GET #{key}: #{e.message}"
      nil
    end

    def redis_set(key, value, expires_in: 3600)
      REDIS_CLIENT.setex(key, expires_in, Marshal.dump(value))
      Rails.logger.info "[REDIS SET] Key: #{key}, TTL: #{expires_in}s"
      true
    rescue Redis::BaseError => e
      Rails.logger.error "[REDIS ERROR] SET #{key}: #{e.message}"
      false
    end

    def redis_delete(key)
      result = REDIS_CLIENT.del(key)
      Rails.logger.info "[REDIS DELETE] Key: #{key}, Deleted: #{result > 0}"
      result
    rescue Redis::BaseError => e
      Rails.logger.error "[REDIS ERROR] DEL #{key}: #{e.message}"
      false
    end

    def redis_fetch(key, expires_in: 3600)
      cached = redis_get(key)
      return cached if cached

      value = yield
      redis_set(key, value, expires_in: expires_in)
      value
    end

    # Memcached operations
    def memcached
      MEMCACHED_CLIENT
    end

    def memcached_get(key)
      value = MEMCACHED_CLIENT.get(key)
      if value
        Rails.logger.info "[MEMCACHED HIT] Key: #{key}"
      else
        Rails.logger.info "[MEMCACHED MISS] Key: #{key}"
      end
      value
    rescue Dalli::DalliError => e
      Rails.logger.error "[MEMCACHED ERROR] GET #{key}: #{e.message}"
      nil
    end

    def memcached_set(key, value, expires_in: 3600)
      MEMCACHED_CLIENT.set(key, value, expires_in)
      Rails.logger.info "[MEMCACHED SET] Key: #{key}, TTL: #{expires_in}s"
      true
    rescue Dalli::DalliError => e
      Rails.logger.error "[MEMCACHED ERROR] SET #{key}: #{e.message}"
      false
    end

    def memcached_delete(key)
      result = MEMCACHED_CLIENT.delete(key)
      Rails.logger.info "[MEMCACHED DELETE] Key: #{key}, Success: #{result}"
      result
    rescue Dalli::DalliError => e
      Rails.logger.error "[MEMCACHED ERROR] DEL #{key}: #{e.message}"
      false
    end

    def memcached_fetch(key, expires_in: 3600)
      cached = memcached_get(key)
      return cached if cached

      value = yield
      memcached_set(key, value, expires_in: expires_in)
      value
    end
  end
end
