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
rep = periodo.select { |row| row["situacao"] == "fsdfsd" }

# teste1 = periodo.map { |row| row["media"] }.sum { |e| e.gsub(",", ".").to_f }
teste1 = periodo.sum(0.0) { |row| row["media"].gsub(",", ".").to_f }

teste2 = rep.sum(0) { |row| row["ch"].to_i }

puts "\n"

def numeric?(string)
  Float(string) != nil rescue false
end

cr_rows = periodo.select { |row| numeric?(row["media"][0]) }
ch_sum = cr_rows.sum(0.0) { |row| (row["media"].gsub(",", ".").to_f) * row["ch"].to_i  }
cr = (ch_sum / (cr_rows.sum(0) { |row| row["ch"].to_i })).round(2)
puts cr

ira_rows = csv.select { |row| numeric?(row["media"][0]) && row["ano_per"] <= "2015.2" }
ch_sum = ira_rows.sum(0.0) { |row| (row["media"].gsub(",", ".").to_f) * row["ch"].to_i  }
ira = (ch_sum / (ira_rows.sum(0) { |row| row["ch"].to_i })).round(2)
puts ira
