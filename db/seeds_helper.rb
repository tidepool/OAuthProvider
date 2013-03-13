module SeedsHelper
  def check_if_inputs_modified(data, *inputs)
    updated_at = data.updated_at if !data.nil?
    if updated_at
      inputs.each do |input|
        input_modified_time = File.mtime(input)
        puts "Data: #{updated_at.to_s} Input: #{input_modified_time.to_s}"
        return true if (updated_at < input_modified_time)
      end
    else
      return true
    end  
    return false
  end
end