class Highfive < ActiveRecord::Base
  include Paginate

  belongs_to :user
  belongs_to :activity_record

end
