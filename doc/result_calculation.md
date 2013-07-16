Levels:

  CirclesTest -> 
    Generates Big5, Holland6, Emo

  ImageRank ->
    Generates Big5

  ReactionTime ->
    Generates Reaction



Big5 -> 
  Uses CirclesTest & ImageRank

Holland6 -> 
  Uses CirclesTest

Emo ->
  Uses CirclesTest

Reaction ->
  Uses ReactionTime


Game can generate multiple results
Game can have multiple levels

Analyzers - Levels
  Every Level Type has a distinct analyzer

Aggregators -
  Calculates the raw scores for -> Big5 & Holland6 across Levels and Level Types

module -> mini_game

------


Ideally:

Level Type
  List of intermediate result types it can produce  
  
Level Instance
  Intermediate Result it produces

Game (contains multiple level instances)
  List of result types it produces


Intermediate Results are aggregated and processed for a game across all level instances.


Example:

MiniGame
  CirclesTest
    overlap, size, distance_relative, distance_rank
  ImageRank
    image_elements
  ReactionTime

CircleAnalysis -> overlap, size, distance_rank, distance_standard   
ElementAnalysis -> image_element_weights

MiniGames -> produce -> IntermediateResults

Big5
  { 
    IntermediateResults
      CircleAnalysis      
    Spreadsheet
      circles.csv
  },
  {
    IntermediateResults
      ElementAnalysis
    Spreadsheet
      element_weights.csv
  }

Holland6
  { 
    IntermediateResults
      overlap, size, distance_rank      
    Spreadsheet
      circles.csv
  }

Emo
  {
    Collected_Data
      distance_standard
    Spreadsheet

  }   