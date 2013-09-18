require 'spec_helper'

class TimeZoneTest 
  include TimeZoneCalculations
end

describe TimeZoneCalculations do 
  it 'calculates the time from a given timezone_offset' do 
    timezone_offset = 3.hours  # Timezone UTC + 3
    test = TimeZoneTest.new
    today = Time.zone.now
    time = test.time_from_offset(today, timezone_offset)    
    time.should == today.in_time_zone(3)
  end

  it 'assumes the timezone is application timezone if timezone value is 999999 ' do 
    timezone_offset = 999999
    test = TimeZoneTest.new
    today = Time.zone.now
    time = test.time_from_offset(today, timezone_offset)    
    time.should == today    
  end

end
