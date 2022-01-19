require_relative "../models/historico"
require 'tempfile'
require 'csv'

#### Uncomment for testing purposes
require 'pdf-reader'

class PagesController < ApplicationController
  def home
  end

  def normativa
  end

  def about
  end

  def upload
    #### Comment for testing purposes
    # if params[:historico].blank?
    #   redirect_to root_path, notice: "O campo de upload não pode estar vazio."
    # elsif File.extname(params[:historico].path) != ".pdf"
    #   redirect_to root_path, notice: "Apenas são aceitos arquivos em formato PDF."
    # elsif (File.size(params[:historico].path).to_f / 2**20).round(3) > 0.300
    #   redirect_to root_path, notice: "O arquivo selecionado não pode ter mais que 2MB."
    # else
    #   parse_uploaded_file
    # end

    #### Uncomment for testing purposes
    reader = PDF::Reader.new(params[:historico].path)
    page_one = reader.page(1).text
    page_one.each_line do |line|
      data = line.split
      (@nome = data[(data.index("Nome:") + 1)..(data.index("Matrícula:") - 1)].join(' ')) if line["Nome:"]
    end
      # (@nome = data[(data.index("Nome:") + 1)..(data.index("Matrícula:") - 1)].join(' ')) if line["Nome:"]
    puts page_one
    puts "O nome do cidadão é: #{@nome}"
    10.times do
      puts "####"
    end
    redirect_to root_path
  end

  private

  def parse_uploaded_file
    @h = Historico.new
    temp = Tempfile.new(['historico', '.csv'])
    @pdf_verified = @h.pdf_is_historico?(params[:historico].path)
    if @pdf_verified
      @h.parse_pdf(params[:historico].path, temp.path)
      # h.parse_pdf(Rails.root.join "app", "assets", "images", "historico_2015070166.pdf")
      historico_csv_analysis(temp.path)
      # redirect_to root_path
    end
    temp.unlink
  end

  def historico_csv_analysis(csv_path)
    csv = CSV.read(csv_path, headers: true)
    @unique_ano_per = csv["ano_per"].uniq.sort
  end
end
