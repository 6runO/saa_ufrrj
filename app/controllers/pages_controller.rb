require_relative "../models/historico"
require 'tempfile'
require 'csv'

class PagesController < ApplicationController
  def home
  end

  def upload
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

  private

  def historico_csv_analysis(csv_path)
    csv = CSV.read(csv_path, headers: true)
    @unique_ano_per = csv["ano_per"].uniq
  end
end
