module AttentionBadgeSerialize
  def attention_badge_for_score(score)
    badges = [
      {
        character: "parakeet",
        title: "Parakeet",
        description: "Who knows why but your brain kind of got up on the wrong side of the bed today, your attention, your working memory, not where they usually are. These times do come and if for not other reason than to remind us we should take some time off from always having to perform at super-high cognitive levels and maybe just read a book for fun or (*gasp*) sit back and chill with some music."
      },
      {
        character: "cockatiel",
        title: "Cockatiel",
        description: "All right, no use in mincing words, your attention skills are not at your best. But that's okay, we all need to recharge and this may be a great time for you to take some time to catch up on reading, emails and calls."
      },
      {
        character: "brownthrasher",
        title: "Brown Thrasher",
        description: "If we were to guess we would say your brain is operating as if it were a rainy Sunday morning. If it is, you are set, put on a pot of coffee and get the crossword puzzle. But if you need to run out the door to work just realize you are not your sharpest and you want to double check your work."
      },
      {
        character: "mockingbird",
        title: "Mockingbird",
        description: "We aren't concerned that you are going to walk out of your house with your jacket on backwards but your attentional skills aren't at their sharpest either. So if you can take some time to catch up and get ready for the next time you are feeling sharper."
      },
      {
        character: "marshwarbler",
        title: "Marshwarbler",
        description: "You attention skills have been better. But take this to heart, your brain works in numerous different ways simultaneously. Right now is a better time to take in than to try to be terribly creative. And that's cool."
      },
      {
        character: "myna",
        title: "Myna",
        description: "You are pretty much in the middle ranges of performance on attentional tasks. It's definitely not a time to put yourself out front if you don't have to. Do some new reading, catch up on emails, stay sharp for the next time you are really in high gear."
      },
      {
        character: "starling",
        title: "Starling",
        description: "You have all around solid attentional skills right now. Not your absolute fastest but a good time to take in new information."
      },
      {
        character: "lyrebird",
        title: "Lyrebird",
        description: "The pattern of performance we see on ECHO indicates you are functioning well on simple and complex attentional tasks. Maybe not as creative as you would like but it may be a good time to learn some new stuff and to plan for the future."
      },
      { 
        character: "africangrey",
        title: "African Grey",
        description: "You are performing at the top of your game in both how much information you can attend to and how well you can perform operations on this new information. Fast, efficient and creative, go for it."
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
    when 4000..4999 then badges[7]
    when 5000..100000 then badges[8]
    end
  end  

end