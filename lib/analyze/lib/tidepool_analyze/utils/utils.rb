module TidepoolAnalyze
  module Utils
    # See for definition: http://en.wikipedia.org/wiki/Standard_score
    def self.zscore(value, mean, sd)
      return 0.0 if sd == 0
      (value - mean) / sd
    end

    def self.tscore(zscore)
      (zscore * 10) + 50
    end

    def self.average(value, count)
      (count == 0) ? 0 : value/count
    end

    def self.merge_across_stages(input_data)
      # Merges array of arrays into one array with contents of the inside arrays
      single_array = []
      input_data.each do | result |
        if result.class == Array
          result.each do | raw_result |
            single_array << raw_result
          end
        else
          single_array << result
        end
      end
      single_array
    end

    def self.load_formula(formula_desc)
      if formula_desc[:formula_path]
        formula_path = formula_desc[:formula_path]
      else
        formula_path = File.expand_path("../../formula_sheets/#{formula_desc[:formula_sheet]}", __FILE__)
      end
      formula_key = formula_desc[:formula_key].to_sym

      i = 0
      attributes = []
      types = []
      formula = {}
      CSV.foreach(formula_path) do |row|
        if i == 0
          # First row contains the attribute names 
          row.each do |value|
            attributes << value.strip.to_sym
          end
        elsif i == 1
          # Second row contains the types
          row.each do |value|
            types << value.strip.to_sym
          end
        else
          values = {}
          row.each_with_index do |value, index|
            case types[index]
            when :integer
              values[attributes[index]] = value.to_i
            when :float
              values[attributes[index]] = value.to_f
            when :string
              values[attributes[index]] = value
            else
              # Error case 
              puts value
            end
          end
          formula[values[formula_key]] = ::OpenStruct.new(values)
        end
        i += 1
      end
      formula
    end
  end
end