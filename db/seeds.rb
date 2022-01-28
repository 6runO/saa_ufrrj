# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#### testes
# require_relative "../app/models/historico"
require 'csv'

# pdf_path = "../scrap/historico_20200038248.pdf"
# pdf_path = "app/assets/images/historico_2015070166.pdf"
# csv_path = Rails.root.join "app", "csv", "historico.csv"
csv_path = "app/csv/historico.csv"

csv = CSV.read(csv_path, headers: true)

periodo = csv.select { |row| row["ano_per"] == "2015.2" }
rep = periodo.select { |row| row["situacao"] == "fdgf4" }

# puts periodo.class
puts periodo.size
print rep.first + 2
