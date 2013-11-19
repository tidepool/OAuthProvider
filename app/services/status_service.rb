class StatusService
  def self.check(key)
    $redis.get(key)
  end

  def self.update(key, status)
    $redis.set(key, status)
  end

  def self.delete(key)
    $redis.del(key)
  end
end