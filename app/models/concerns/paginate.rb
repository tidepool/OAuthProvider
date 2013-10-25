module Paginate
  extend ActiveSupport::Concern

  module ClassMethods
    def paginate(query, params)
      return query, {} unless params[:limit] && params[:offset]
      total = query.count

      defaults = {
        limit: 20,
        offset: 0,
        total: total
      }

      api_status = generate_status(params, defaults)
      paginated_query = query.limit(api_status.limit) 
      paginated_query = paginated_query.offset(api_status.offset)
      return paginated_query, api_status
    end

    def generate_status(params, defaults)
      limit = (params[:limit] || defaults[:limit]).to_i
      offset = (params[:offset] || defaults[:offset]).to_i
      total = defaults[:total].to_i

      next_offset = offset + limit 
      if next_offset < total
        next_limit =  (total - next_offset) < limit ? total - next_offset : limit             
      else
        next_offset = 0
        next_limit = limit   
      end
      api_status = Hashie::Mash.new({
        'offset' => offset,
        'limit' => limit,
        'next_offset' => next_offset,
        'next_limit' => next_limit,
        'total' => total
      })
    end    
  end
end