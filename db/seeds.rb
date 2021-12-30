# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)


#testes
require_relative "../app/models/historico"
require 'csv'

# pdf_path = "../scrap/historico_20200038248.pdf"
pdf_path = "app/assets/images/historico_2015070166.pdf"
# pdf_path = Rails.root.join "app", "assets", "images", "historico_2015070166.pdf"
csv_path = "app/csv/historico.csv"

h = Historico.new

result = h.pdf_is_historico?(pdf_path)

h.parse_pdf(pdf_path, csv_path)

csv = CSV.read(csv_path, headers: true)

unique_ano_per = csv["ano_per"].uniq

puts unique_ano_per
puts h.nome
puts h.matricula
puts result
