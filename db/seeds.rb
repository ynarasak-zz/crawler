# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require "csv"
Require.destroy_all
CSV.foreach('db/require.csv') do |row|
  Require.create(:word => row[0])
end

Keyword.destroy_all
CSV.foreach('db/keyword.csv', :skip_lines => /^#.*$/) do |row|
  Keyword.create(:company_name => row[0], :owner => row[1])
end
