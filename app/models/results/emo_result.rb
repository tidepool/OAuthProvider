class EmoResult < Result
  store_accessor :score, :factor1
  store_accessor :score, :factor2
  store_accessor :score, :factor3
  store_accessor :score, :factor4
  store_accessor :score, :factor5
  store_accessor :score, :strongest_emotion
  store_accessor :score, :weakest_emotion
  store_accessor :score, :all_under_20_percentile

end
