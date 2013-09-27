module Tidepool
  module TimeHelper
    def self.time_from_unknown_format(time_input)
      result = nil
      case time_input.class.to_s
      when "Date"
        result = Time.zone.parse(time_input.to_s)
      when "DateTime", "Time", "ActiveSupport::TimeWithZone"
        result = Time.zone.at(time_input)
      when "String"
        result = Time.zone.parse(time_input)
      when "Fixnum", "Integer"
        result = Time.zone.at(time_input)
      end
      result
    end
  end
end