# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)
# require 'csv'
require File.expand_path('../seeds_helper', __FILE__)

Dir[File.expand_path('../seeds/*.rb', __FILE__)].each do |file| 
	require file

	filename = File.basename(file, '.rb')
	klass_name = "#{filename.camelize}"
  seed = klass_name.constantize.new
  seed.create_seed()
end

