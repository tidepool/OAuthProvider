require 'spec_helper'
# require 'yaml'

module TidepoolAnalyze
  describe Utils do 
    it 'loads the formula for big5 circles' do
      formula_desc = {
              formula_sheet: 'big5_circles.csv',
              formula_key: 'name_pair' }
      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      formula["Sociable/Adventurous"].should_not be_nil
      formula.length.should == 10

      circle_data = formula["Sociable/Adventurous"] 
      circle_data.name_pair.should == "Sociable/Adventurous"
      circle_data.id == 1
      circle_data.size_weight.should_not be_nil
      circle_data.size_sd.should_not be_nil
      circle_data.size_mean.should_not be_nil
    end

    it 'loads the formula for holland6 circles' do
      formula_desc = {
              formula_sheet: 'holland6_circles.csv',
              formula_key: 'name_pair' }
      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      formula["Persuasive/Enthusiastic"].should_not be_nil
      formula.length.should == 6

      circle_data = formula["Persuasive/Enthusiastic"] 
      circle_data.name_pair.should == "Persuasive/Enthusiastic"
      circle_data.id == 14
      circle_data.size_weight.should == 0.9
      circle_data.size_sd.should == 1.4
      circle_data.size_mean.should == 3.34
    end

    it 'loads the formula for elements' do
      formula_desc = {
              formula_sheet: 'elements.csv',
              formula_key: 'name' }
      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      formula["caucasian"].should_not be_nil
      formula.length.should == 172
      
      element_data = formula["caucasian"] 
      element_data.name.should == "caucasian"
      element_data.id == 35
      element_data.standard_deviation.should == 3.376691
      element_data.mean.should == 9.29876
      element_data.weight_extraversion.should == 0
    end

    it 'loads the formula for reaction_time_demand' do 
      formula_desc = {
              formula_sheet: 'reaction_time_demand.csv',
              formula_key: 'calculation' }
      formula = TidepoolAnalyze::Utils::load_formula(formula_desc)
      formula.length.should == 3
      statistic_data = formula['average_simple_complex_reaction_time']
      statistic_data.mean.should == 1.070448
      statistic_data.std.should == 0.197141
    end
  end


end
