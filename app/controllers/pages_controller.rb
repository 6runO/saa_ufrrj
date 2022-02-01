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
      csv = CSV.read(temp.path, headers: true)
      call_global_variables
      csv_analysis(csv)
    end
    temp.unlink
  end

  def call_global_variables
    @hrs_aproveitado_regulares = []
    @hrs_aproveitado_atividades = []
    @hrs_apr_regulares = []
    @hrs_apr_eletivas = []
    @hrs_apr_atividades = []
    @hrs_rep_media_regulares_eletivas = []
    @hrs_rep_media_atividades = []
    @hrs_rep_falta_regulares_eletivas = []
    @hrs_rep_falta_atividades = []
    @hrs_matriculado_regulares = []
    @hrs_matriculado_eletivas = []
    @hrs_matriculado_atividades = []
    @num_rep_falta_regulares_eletivas = []
    @num_trancado = []
    @num_cancelado = []
    @hrs_cursado_regulares_eletivas = []
    @cr = []
    @ira = []
  end

  def csv_analysis(csv)
    @unique_ano_per = csv["ano_per"].uniq.sort
    @unique_ano_per.each do |ano_per|
      csv_ano_per = csv.select { |row| row["ano_per"] }

      situacoes_aproveitado = ["CUMPRIU", "TRANSFERIDO", "INCORPORADO", "DISPENSADO"]
      situacoes_apr = ["APR", "APRN"]
      situacoes_rep_media = ["REP", "REPN"]
      situacoes_rep_falta = ["REPF", "REPMF", "REPNF"]
      #### As situações matriculado, trancado e cancelado não precisam de array, pois só possuem um item

      tipos_regulares = ["", "*", "e", "&"]
      tipos_atividades = ["@", "§"]
      #### O tipo eletivo não precisa de array, pois só possui um item

      aproveitado_regulares = csv_ano_per.select { |row| situacoes_aproveitado.include?(row['situacao']) && tipos_regulares.include?(row['tipo']) }
      aproveitado_atividades = csv_ano_per.select { |row| situacoes_aproveitado.include?(row['situacao']) && tipos_atividades.include?(row['tipo']) }
      apr_regulares = csv_ano_per.select { |row| situacoes_apr.include?(row['situacao']) && tipos_regulares.include?(row['tipo']) }
      apr_eletivas = csv_ano_per.select { |row| situacoes_apr.include?(row['situacao']) && row["tipo"] == "#" }
      apr_atividades = csv_ano_per.select { |row| situacoes_apr.include?(row['situacao']) && tipos_atividades.include?(row['tipo']) }
      rep_media_regulares_eletivas = csv_ano_per.select { |row| situacoes_rep_media.include?(row['situacao']) && row["media"] != "--" }
      rep_media_atividades = csv_ano_per.select { |row| situacoes_rep_media.include?(row['situacao']) && row["media"] == "--" }
      rep_falta_regulares_eletivas = csv_ano_per.select { |row| situacoes_rep_falta.include?(row['situacao']) && row["media"] != "--" }
      rep_falta_atividades = csv_ano_per.select { |row| situacoes_rep_falta.include?(row['situacao']) && row["media"] == "--" }
      matriculado_regulares = csv_ano_per.select { |row| row["situacao"] == "MATRICULADO" && tipos_regulares.include?(row['tipo']) }
      matriculado_eletivas = csv_ano_per.select { |row| row["situacao"] == "MATRICULADO" && row["tipo"] == "#" }
      matriculado_atividades = csv_ano_per.select { |row| row["situacao"] == "MATRICULADO" && tipos_atividades.include?(row['tipo']) }
      trancado = csv_ano_per.select { |row| row["situacao"] == "TRANCADO" }
      cancelado = csv_ano_per.select { |row| row["situacao"] == "CANCELADO" }

      @hrs_aproveitado_regulares << (aproveitado_regulares.sum(0) { |row| row["ch"].to_i })
      @hrs_aproveitado_atividades << aproveitado_atividades.sum(0) { |row| row["ch"].to_i }
      @hrs_apr_regulares << apr_regulares.sum(0) { |row| row["ch"].to_i }
      @hrs_apr_eletivas << apr_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_apr_atividades << apr_atividades.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_media_regulares_eletivas << rep_media_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_media_atividades << rep_media_atividades.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_falta_regulares_eletivas << rep_falta_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_falta_atividades << rep_falta_atividades.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_regulares << matriculado_regulares.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_eletivas << matriculado_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_atividades << matriculado_atividades.sum(0) { |row| row["ch"].to_i }
      @num_rep_falta_regulares_eletivas << rep_falta_regulares_eletivas.size
      @num_trancado << trancado.size
      @num_cancelado << cancelado.size

      csv_analysis_indexes(csv, ano_per, csv_ano_per)
    end
  end

  def csv_analysis_indexes(csv, ano_per, csv_ano_per)
    @hrs_cursado_regulares_eletivas << @hrs_apr_regulares + @hrs_apr_eletivas + @hrs_rep_media_regulares_eletivas + @hrs_rep_falta_regulares_eletivas

    cr_rows = csv_ano_per.select { |row| numeric?(row["media"][0]) }
    ch_sum = cr_rows.sum(0.0) { |row| (row["media"].gsub(",", ".").to_f) * row["ch"].to_i  }
    cr = cr_rows.empty? ? 0.0 : (ch_sum / (cr_rows.sum(0) { |row| row["ch"].to_i })).round(2)
    @cr << cr

    ira_rows = csv.select { |row| numeric?(row["media"][0]) && row["ano_per"] <= ano_per }
    ch_sum = ira_rows.sum(0.0) { |row| (row["media"].gsub(",", ".").to_f) * row["ch"].to_i  }
    ira = ira_rows.empty? ? 0.0 : (ch_sum / (ira_rows.sum(0) { |row| row["ch"].to_i })).round(2)
    @ira << ira
  end
end
