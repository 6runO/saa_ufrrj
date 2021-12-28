require_relative "../models/historico"

class PagesController < ApplicationController
  def home
    # PDF::Reader.new(Rails.root.join "app", "assets", "images", "historico_2015070166.pdf")
    @f ||= "kjsdf"
  end

  def upload
    # raise
    h = Historico.new
    h.parse_pdf(params[:historico].path)
    # h.parse_pdf(Rails.root.join "app", "assets", "images", "historico_2015070166.pdf")
    @f = h.nome
    # redirect_to root_path
  end
end
