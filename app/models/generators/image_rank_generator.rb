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
    images = Rails.cache.fetch(image_id_sequence, expires_in: 1 day) do 
      Image.where(name: image_id_sequence).to_a
    end
    images.each do |image|
      if (Rails.env.production?)
        # TODO: S3 based location for the images
        image_url = "/images/devtest_images/#{image.name}.jpg"
      else
        image_url = "/images/devtest_images/#{image.name}.jpg"
      end        
      image_sequence << { image_id: image.name, elements: image.elements, url: image_url}      
    end

    result["image_sequence"] = image_sequence
    result
  end
end
