class EmotionsCirclesGenerator
  def initialize(stage_template)
    @stage_template = stage_template
  end

  def generate
    # result = {}
    # result["friendly_name"] = @stage_template["friendly_name"]
    # result["instructions"] = @stage_template["instructions"]
    # result["view_name"] = @stage_template["view_name"]

    # image_sequence = []
    # circle_sequence = @stage_template["circles"]
    # circle_sequence.each do |image|
    #   if (Rails.env.production?)
    #     # TODO: S3 based location for the images
    #     image_url = "/images/emotions_images/#{image["image_id"]}.jpg"
    #   else
    #     image_url = "/images/emotions_images/#{image["image_id"]}.jpg"
    #   end        

    #   image_sequence << { trait: image["trait"], 
    #     image_id: image["image_id"], 
    #     url: image_url
    #   }
    # end
    # result["circles"] = image_sequence
    # result
    @stage_template
  end
end