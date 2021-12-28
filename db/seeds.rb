# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#testes
# require_relative "../app/models/historico"
def numerico?(string)
  Float(string) != nil rescue false
end

a = "SCHMITT6030h60"
b = "900h)90"

# if numerico?(a.chars.last(3).join)
#   puts "last 3 numeric: '#{a.chars.last(3).join}'"
# elsif numerico?(a.chars.last(2).join)
#   puts "last 2 numeric: '#{a.chars.last(2).join}'"
# elsif numerico?(a.chars.last)
#   puts "last 1 numeric: '#{a.chars.last}'"
# else
#   puts "last 1 not numeric: '#{a.chars.last}'"
# end

def number_right_to_array(string)
  if numerico?(string.chars.last(3).join)
    return string.chars.last(3).join.split
  elsif numerico?(string.chars.last(2).join)
    return string.chars.last(2).join.split
  elsif numerico?(string.chars.last)
    return string.chars.last.split
  else
    return ["0"]
  end
end

puts number_right_to_array(a)
