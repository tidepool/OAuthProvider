class ApiStatus
  attr_reader :status
  
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  def persisted?  
    false
  end

  def initialize(status_info)
    @status = status_info
  end

end