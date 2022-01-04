require_relative "../models/historico"
require 'tempfile'
require 'csv'

class PagesController < ApplicationController
  def home
  end

  def upload
    if params[:historico].blank?
      redirect_to root_path, notice: "O campo de upload não pode estar vazio."
    elsif File.extname(params[:historico].path) != ".pdf"
      redirect_to root_path, notice: "Apenas são aceitos arquivos em formato PDF."
    elsif (File.size(params[:historico].path).to_f / 2**20).round(3) > 0.300
      redirect_to root_path, notice: "O arquivo selecionado não pode ter mais que 2 MB (Mega Bytes)."
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
