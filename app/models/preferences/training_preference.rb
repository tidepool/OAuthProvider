class TrainingPreference < Preference

  def description
    [
      {
        name: 'daily_emotion',
        description: 'Track my emotions daily so I can see how often I change my mood',
        type: 'checkbox',
        category: 'emotions'
      }
    ]
  end

end