module Paginate
  extend ActiveSupport::Concern

  module ClassMethods
    def paginate(query, params)
      limit = params[:limit].to_i
      offset = params[:offset].to_i
      return query, {} unless limit && offset && limit != 0

      paginated_query = query.limit(limit) 
      paginated_query = paginated_query.offset(offset)

      next_offset = offset + limit 
      prev_offset = offset - limit 
      prev_offset = 0 if prev_offset < 0
      api_status = Hashie::Mash.new({
        'offset' => offset,
        'limit' => limit,
        'next' => "?offset=#{next_offset}&limit=#{limit}",
        'prev' => "?offset=#{prev_offset}&limit=#{limit}"
      })

      return paginated_query, api_status
    end
  end
end