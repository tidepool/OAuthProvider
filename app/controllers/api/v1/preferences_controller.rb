class Api::V1::PreferencesController < Api::V1::ApiController
  doorkeeper_for :all

  def show
    preference = Preference.where('user_id = ? and type = ?', target_user.id, params[:type]).first
    respond_to do |format|
      format.json { render({ json: preference, serializer: PreferenceSerializer, meta: {} }.merge(api_defaults)) }
    end
  end

  def create
    pref_type = params[:preference][:type]
    pref_data = params[:preference][:data]
    preference = Preference.where('user_id = ? and type = ?', target_user.id, pref_type).first
    if preference.nil?      
      preference = target_user.preferences.build(:type => pref_type)
      preference.data = pref_data
      preference.save!
    end

    respond_to do |format|
      format.json { render({ json: preference, serializer: PreferenceSerializer, meta: {} }.merge(api_defaults)) }
    end    
  end

  def update
    pref_type = params[:preference][:type]
    pref_data = params[:preference][:data]
    preference = Preference.where('user_id = ? and type = ?', target_user.id, pref_type).first
    
    preference.update(pref_data) if preference

    respond_to do |format|
      format.json { render({ json: preference, serializer: PreferenceSerializer, meta: {} }.merge(api_defaults)) }
    end    
  end

  def description
    pref_type = params[:type].underscore.camelize
    pref_class = pref_type.constantize

    respond_to do |format|
      format.json { render({ json: pref_class.description, meta: {} }.merge(api_defaults)) }
    end              
  end

  protected

  def current_resource
    target_user
  end

  def preference_params
    params.require(:preference).permit(:data)  
  end
end