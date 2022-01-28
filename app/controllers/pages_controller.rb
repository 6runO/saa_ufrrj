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

  def numeric?(string)
    Float(string) != nil rescue false
  end

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
      csv_ano_per = csv.select { |row| row["ano_per"] }

      situacoes_aproveitado = ["CUMPRIU", "TRANSFERIDO", "INCORPORADO", "DISPENSADO"]
      situacoes_apr = ["APR", "APRN"]
      situacoes_rep_media = ["REP", "REPN"]
      situacoes_rep_falta = ["REPF", "REPMF", "REPNF"]
      #### As situações matriculado, trancado e cancelado não precisam de array, pois só possuem um item

      aproveitado = csv_ano_per.select { |row| situacoes_aproveitado.include?(row['situacao']) }
      apr = csv_ano_per.select { |row| situacoes_apr.include?(row['situacao']) }
      rep_media = csv_ano_per.select { |row| situacoes_rep_media.include?(row['situacao']) }
      rep_falta = csv_ano_per.select { |row| situacoes_rep_falta.include?(row['situacao']) }
      matriculado = csv_ano_per.select { |row| row["situacao"] == "MATRICULADO" }
      trancado = csv_ano_per.select { |row| row["situacao"] == "TRANCADO" }
      cancelado = csv_ano_per.select { |row| row["situacao"] == "CANCELADO" }

      tipos_regulares = ["", "*", "e", "&"]
      tipos_atividades = ["@", "§"]
      #### O tipo eletivo não precisa de array, pois só possui um item

      aproveitado_regulares = aproveitado.select { |row| tipos_regulares.include?(row['tipo']) }
      aproveitado_atividades = aproveitado.select { |row| tipos_atividades.include?(row['tipo']) }
      apr_regulares = apr.select { |row| tipos_regulares.include?(row['tipo']) }
      apr_eletivas = apr.select { |row| row["tipo"] == "#" }
      apr_atividades = apr.select { |row| tipos_atividades.include?(row['tipo']) }
      rep_media_regulares_eletivas = rep_media.select { |row| row["media"] != "--" }
      rep_media_atividades = rep_media.select { |row| row["media"] == "--" }
      rep_falta_regulares_eletivas = rep_falta.select { |row| row["media"] != "--" }
      rep_falta_atividades = rep_falta.select { |row| row["media"] == "--" }
      matriculado_regulares = matriculado.select { |row| tipos_regulares.include?(row['tipo']) }
      matriculado_eletivas = matriculado.select { |row| row["tipo"] == "#" }
      matriculado_atividades = matriculado.select { |row| tipos_atividades.include?(row['tipo']) }
      #### Os arrays trancado e cancelado já estão prontos, pois não precisam ser filtrados quanto ao tipo



      @hrs_aproveitado_regulares =
      @hrs_aproveitado_atividades =
      @hrs_apr_regulares =
      @hrs_apr_eletivas =
      @hrs_apr_atividades =
      @hrs_rep_media_regulares_eletivas =
      @hrs_rep_media_atividades =
      @hrs_rep_falta_regulares_eletivas =
      @hrs_rep_falta_atividades =
      @hrs_matriculado_regulares =
      @hrs_matriculado_eletivas =
      @hrs_matriculado_atividades =
      @num_rep_falta_regulares_eletivas =
      @num_trancado
      @num_cancelado

      #cr e índices

      csv_analysis_by_line(csv, ano_per)
    end
  end

  def csv_analysis_by_line(csv, ano_per)
    csv.each do |row|
      # ira


    end
  end
end
