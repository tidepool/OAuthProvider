module EmoBadgeSerialize
  def badge_for_score(score)
    badges = [
      { 
        character: "sheldon",
        title: "Know It All.. Not",
        description: "If you ever thought intellectual ability was all you needed to succeed, you are for a \"Big Bang\". Emotional intelligence is the ability to be aware of your own emotions, cope with change, understand the needs of others and maintain positive relationships with people."
      },
      {
        character: "trump",
        title: "",
        description: ""
      },
      {
        character: "steve",
        title: "",
        description: ""        
      },
      {
        character: "einstein",
        title: "Genius",
        description: "You are good at combining your intelligence with understanding people around you. This unique combination will help you excel at work and in your relationships."
      },
      {
        character: "abe",
        title: "Honest Abe",
        description: "Your ability to regulate your own emotions is key for your extraordinary levels of humility. Humility does not come easy to any leader, and you might achieve more due to your unique levels of EQ."
      },
      {
        character: "walt",
        title: "Imagineer",
        description: "A person with such high emotional intelligence can be very pragmatic because of your skills to understand people around you. You can use this to steer groups for forming new ideas and inspiring to achieve dreams."
      },
      {
        character: "oprah",
        title: "Talk Shaw Diva",
        description: "You are powerful in the sense that lot of people look to you in times of need. Not only will you guide people with your intelligent advice but you can also express empathy very well. Your strength in emotional intelligence makes you a authentic leader in your field."
      }
    ]

    badge = case score.to_i 
    when 0..999 then badges[0]
    when 1000..1999 then badges[1]
    when 2000..2999 then badges[2]
    when 3000..3999 then badges[3]
    when 4000..4999 then badges[4]
    when 5000..5999 then badges[5]
    when 6000..100000 then badges[6]
    end
  end  

end