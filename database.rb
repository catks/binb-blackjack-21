require "rubygems"
require "sequel"

# connect to an in-memory database
DB = Sequel.sqlite('blackjack.db')

# create an items table
DB.create_table? :scores do
  primary_key :id
  String :player
  Int :victories
  Int :draws
  Int :losses
end

class Score < Sequel::Model
end
