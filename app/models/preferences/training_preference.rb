class TrainingPreference < Preference

  def description
    [
      {
        name: 'more_in_less_time',
        description: 'Accomplish more in less time',
        type: 'checkbox',
        category: 'productivity'
      },
      {
        name: 'stay_focused',
        description: 'Stay focused on what is important',
        type: 'checkbox',
        category: 'productivity'
      },
      {
        name: 'emotional_cycles',
        description: 'Understand your daily emotional cycles',
        type: 'checkbox',
        category: 'productivity'
      },
      {
        name: 'multi_task',
        description: 'Multi-task and prioritize effectively in dynamic environments',
        type: 'checkbox',
        category: 'productivity'
      },
      {
        name: 'support_networks',
        description: 'Develop support networks for personal and professional fufillment',
        type: 'checkbox',
        category: 'productivity'
      },
      {
        name: 'emotional_energy',
        description: 'Channel your emotional energy to confront and conquor problems',
        type: 'checkbox',
        category: 'mood'
      },
      {
        name: 'more_rested',
        description: 'Feel more rested with the same amount of sleep',
        type: 'checkbox',
        category: 'mood'
      },
      {
        name: 'stress_points',
        description: 'Understand and improve stress points with friends, colleagues and spouses',
        type: 'checkbox',
        category: 'mood'
      },
      {
        name: 'stop_panic',
        description: "Stop panic, don't let it control you",
        type: 'checkbox',
        category: 'mood'
      },
      {
        name: 'speak_with_purpose',
        description: 'Speak with purpose in front of any size of group',
        type: 'checkbox',
        category: 'mood'
      }
    ]
  end

end
