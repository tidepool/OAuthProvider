module RedisHelpers
  # From: http://mrdanadams.com/2012/pipeline-redis-commands-ruby/#.UmWTG2RgYd5
  class Pipeliner
    def initialize(redis)
      @redis = redis
      @cmds = []
    end

    def enqueue(future, &proc)
      @cmds << { future: future, callback: proc }
    end

    def wait
      @cmds.each do |c|
        while c[:future].value.is_a?(Redis::FutureNotReady)
          sleep(1.0 / 100.0)
        end

        c[:callback].call c[:future].value
      end
    end

    def self.pipeline(redis, &proc)
      # Executes callbacks with each result. This blocks.
      pipeliner = Pipeliner.new redis
      redis.pipelined do
        proc.call pipeliner
      end

      pipeliner.wait
    end
  end
end