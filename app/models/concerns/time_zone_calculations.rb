module TimeZoneCalculations
  extend ActiveSupport::Concern

  def time_from_offset(time, timezone_offset)
    timezone_offset = timezone_offset_in_hours(timezone_offset)
    time.in_time_zone(timezone_offset)
  end

  def timezone_offset_in_hours(timezone_offset)
    # 999999 is the default if we don't have any timezone knowledge for legacy clients
    # Assume that they are in the same zone as the application (Pacific time)
    timezone_offset = Time.zone.now.utc_offset if timezone_offset == 999999 || timezone_offset.nil?
    timezone_offset/3600
  end

end