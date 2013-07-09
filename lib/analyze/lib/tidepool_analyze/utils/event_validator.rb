module TidepoolAnalyze
  module Utils
    module EventValidator
      def user_event_valid?(user_event)
        return false if !user_event["event_desc"]
        return false if !user_event["module"]
        return false if !user_event["record_time"]
        return false if !user_event["game_id"]
        return false if !user_event["stage"]

        schema_name = "#{user_event["module"]}_events.json"
        @event_schema ||= load_schema(schema_name)
        event_desc = user_event["event_desc"]
        is_valid = true
        if @event_schema[event_desc]
          @event_schema[event_desc].each do |event_name, value|
            unless user_event.has_key?(event_name)
              is_valid = false
              @invalid_event = user_event
              break
            end
          end
        end
        is_valid
      end

      def load_schema(schema_name)
        schema_json = IO.read(File.expand_path("../../user_events/#{schema_name}", __FILE__))
        schema = JSON.parse(schema_json)
      end

      def invalid_event
        @invalid_event
      end
    end
  end
end
