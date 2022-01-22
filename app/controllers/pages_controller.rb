require_relative "../models/historico"
require 'tempfile'
require 'csv'

class PagesController < ApplicationController
  def home
  end

  def normativa
  end

  def about
  end

  def upload
    if params[:historico].blank?
      redirect_to root_path, notice: "O campo de upload não pode estar vazio."
    elsif File.extname(params[:historico].path) != ".pdf"
      redirect_to root_path, notice: "Apenas são aceitos arquivos em formato PDF."
    elsif (File.size(params[:historico].path).to_f / 2**20).round(3) > 0.300
      redirect_to root_path, notice: "O arquivo selecionado não pode ter mais que 2MB."
    else
      parse_uploaded_file
    end
  end

  private

  def parse_uploaded_file
    @h = Historico.new
    temp = Tempfile.new(['historico', '.csv'])
    @pdf_verified = @h.pdf_is_historico?(params[:historico].path)
    if @pdf_verified
      @h.parse_pdf(params[:historico].path, temp.path)
      # h.parse_pdf(Rails.root.join "app", "assets", "images", "historico_2015070166.pdf")
      csv = CSV.read(temp.path, headers: true)
      csv_analysis_by_table(csv)
    end
    temp.unlink
  end

  def csv_analysis_by_table(csv)
    @unique_ano_per = csv["ano_per"].uniq.sort
    @unique_ano_per.each do |ano_per|

      csv_analysis_by_line(csv, ano_per)
    end
  end

  def csv_analysis_by_line(csv, ano_per)
    csv.each do |row|

    end
  end
end
