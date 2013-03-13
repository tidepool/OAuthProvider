class ImageRankGenerator
  def initialize(stage_template)
    @stage_template = stage_template
  end

  def generate
    result = {}
    result["friendly_name"] = @stage_template["friendly_name"]
    result["instructions"] = @stage_template["instructions"]
    result["view_name"] = @stage_template["view_name"]

    image_sequence = []
    image_id_sequence = @stage_template["image_sequence"]
    image_id_sequence.each do |image_id|
      image = Image.where(name: image_id).first
      if !image.nil?
        image_url = ""
        if (Rails.env.production?)
          # TODO: S3 based location for the images
          image_url = "/assets/devtest_images/#{image_id}.jpg"
        else
          image_url = "/assets/devtest_images/#{image_id}.jpg"
        end        
        image_sequence << { image_id: image_id, elements: image.elements, url: image_url}
      end
    end
    result["image_sequence"] = image_sequence
    result
  end
end
