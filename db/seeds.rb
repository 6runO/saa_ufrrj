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

def numeric?(string)
  Float(string) != nil rescue false
end

puts "\n"

hrs_apr_regulares = []

unique_ano_per = csv["ano_per"].uniq.sort
puts "\n"
print "unique_ano_per: #{unique_ano_per}"

unique_ano_per.each do |ano_per|
  csv_ano_per = csv.select { |row| row["ano_per"] == ano_per }

  situacoes_aproveitado = ["CUMPRIU", "TRANSFERIDO", "INCORPORADO", "DISPENSADO"]
  situacoes_apr = ["APR", "APRN"]
  situacoes_rep_media = ["REP", "REPN"]
  situacoes_rep_falta = ["REPF", "REPMF", "REPNF"]
  #### As situações matriculado, trancado e cancelado não precisam de array, pois só possuem um item

  tipos_regulares = ["", "*", "e", "&"]
  tipos_atividades = ["@", "§"]
  #### O tipo eletivo não precisa de array, pois só possui um item

  apr_regulares = csv_ano_per.select { |row| (situacoes_apr.include?(row['situacao'])) && (tipos_regulares.include?(row['tipo'])) }

  puts "\n"
  puts apr_regulares.sum(0) { |row| row["ch"].to_i }

  hrs_apr_regulares << apr_regulares.sum(0) { |row| row["ch"].to_i }
  puts "\n"
  puts "apr_regulares: #{hrs_apr_regulares}"
end
