class Api::V1::CommentsController < Api::V1::ApiController
  doorkeeper_for :all

  def index 
    query = Comment.joins(:user).select("comments.*, users.email as user_email, users.name as user_name, users.image as user_image")
    query = query.where(activity_record_id: params[:activity_record_id])
    query = query.order(updated_at: :desc)

    comments, api_status = Comment.paginate(query, params) 

    respond_to do |format|
      format.json { render({ json: comments, meta: api_status, each_serializer: CommentSummarySerializer }.merge(api_defaults))  }
    end
  end

  def create
    activity_record = ActivityRecord.find(params[:activity_record_id])
    comment = activity_record.comments.build(comment_attributes)
    comment.user = target_user
    comment.save!

    respond_to do |format|
      format.json { render({ json: comment, meta: {} }.merge(api_defaults))  }
    end    
  end

  def show
    comment = Comment.find(params[:id])

    respond_to do |format|
      format.json { render({ json: comment, meta: {} }.merge(api_defaults))  }
    end
  end

  def update
    comment = Comment.find(params[:id])
    comment.update_attributes(comment_attributes)

    respond_to do |format|
      format.json { render({ json: comment, meta: {} }.merge(api_defaults))  }
    end    
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy!

    respond_to do |format|
      format.json { render({ json: {}, meta: {} }.merge(api_defaults))  }
    end        
  end

  private 

  def current_resource
    target_user
  end

  def comment_attributes
    params.require(:comment).permit(:text)  
  end
end