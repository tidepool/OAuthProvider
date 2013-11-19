module AttentionBadgeSerialize
  def badge_for_score(score)
    badges = [
      { 
        character: "africangrey",
        title: "African Grey",
        description: "If you ever thought intellectual ability was all you needed to succeed, you are up for a \"Big Bang\". It seems you can resonate well with this modern day hero; emotions simply escape you. Understanding emotions is just not a strength at the moment. You can improve your effectiveness by engaging in emotional training and focusing on the strong aspects of your personality."
      },
      {
        character: "brownthrasher",
        title: "Brown Thrasher",
        description: "The character represented here uses their Low EI for success. The stereotype of the hard-driving salesperson/entrepreneur not only fails to process emotions they practice the art of causing emotional turmoil to their own advantage. Low EI does not mean a lack of success. We encourage you to chose less self-centered means of finding satisfaction and train more for understanding other's emotions."
      },
      {
        character: "cockatiel",
        title: "Cockatiel",
        description: "Some of the most successful people of our generation were by all appearances very attuned to EI. Well, truth be known it is possible to have some failures in emotional regulation, and still be successful beyond all but the wildest dreams. Your EI is such that with insight, training and openness to areas of strength from your personality there is no limit to your effectiveness."        
      },
      {
        character: "lyrebird",
        title: "Lyrebird",
        description: "Perhaps no one demonstrates the malleability of EI more than this man who can easily be argued to have accomplished more with his life than all but a few people ever did. While he certainly wasn’t without rough edges in his ability to understand emotions, he was able to find the emotional support he needed to do the work that has changed our world forever. Given your own variability in EI we suspect you can resonate and even benefit by considering how far you can go by finding and nurturing the support you need."
      },
      {
        character: "mockingbird",
        title: "Mockingbird",
        description: "You clearly have a high level of ability to understand and manage your emotions. EI is not the only important fact you need to consider as you move toward a life of personal satisfaction and effectiveness. Consider this icon who despite an unbelievable level of EI struggled with his own internal weaknesses and remember to not only consider the emotions of others but also what you need to nurture you own spirit."
      },
      {
        character: "marshwarbler",
        title: "Marshwarbler",
        description: "Few people have been able to understand the emotional dreams of people as did the man who brought these dreams onto the silver screen.  A person with such high emotional intelligence can be very pragmatic because of your skills to understand people around you. You can use this to steer groups for forming new ideas and inspiring to achieve dreams."
      },
      {
        character: "myna",
        title: "Myna",
        description: "Many people of great effectiveness like this icon, you are powerful in the sense that lot of people look to you in times of need. Not only will you guide people with your intelligent advice but you can also express empathy very well. Your strength in emotional intelligence makes you a authentic leader in your field."
      },
      {
        character: "parakeet",
        title: "Parakeet",
        description: "Many people of great effectiveness like this icon, you are powerful in the sense that lot of people look to you in times of need. Not only will you guide people with your intelligent advice but you can also express empathy very well. Your strength in emotional intelligence makes you a authentic leader in your field."
      },
      {
        character: "starling",
        title: "Starling",
        description: "Many people of great effectiveness like this icon, you are powerful in the sense that lot of people look to you in times of need. Not only will you guide people with your intelligent advice but you can also express empathy very well. Your strength in emotional intelligence makes you a authentic leader in your field."
      }
    ]

    badge = case score.to_i 
    when 0..249 then badges[0]
    when 250..749 then badges[1]
    when 750..999 then badges[2]
    when 1000..1499 then badges[3]
    when 1500..1999 then badges[4]
    when 2000..2999 then badges[5]
    when 3000..3999 then badges[6]
    when 4000..4999 then badges[6]
    when 5000..100000 then badges[6]
    end
  end  

end