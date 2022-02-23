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
      global_arrays
      global_arrays_averages
      csv_analysis(csv)
      geral_summaries
    end
    temp.unlink
  end

  def global_arrays
    @hrs_aproveitado_regulares = []
    @hrs_aproveitado_atividades = []
    @hrs_apr_regulares = []
    @hrs_apr_eletivas = []
    @hrs_apr_regulares_eletivas = []
    @hrs_apr_atividades = []
    @hrs_rep_media_regulares_eletivas = []
    @hrs_rep_media_atividades = []
    @hrs_rep_falta_regulares_eletivas = []
    @hrs_rep_falta_atividades = []
    @hrs_cursado_regulares_eletivas = []
    @hrs_matriculado_regulares = []
    @hrs_matriculado_eletivas = []
    @hrs_matriculado_atividades = []
    @num_rep_falta_regulares_eletivas = []
    @num_trancado = []
    @num_cancelado = []
    @ratio_apr = []
    @cr = []
    @ira = []
    @contrapartida_resultado = []
    @contrapartida_motivo = []
  end

  def global_arrays_averages
    @average_curso_hrs_aproveitado_regulares_atividades = []
    @average_curso_hrs_apr_regulares_eletivas = []
    @average_curso_hrs_apr_atividades = []
    @average_curso_hrs_rep_media_regulares_eletivas = []
    @average_curso_hrs_rep_media_atividades = []
    @average_curso_hrs_rep_falta_regulares_eletivas = []
    @average_curso_hrs_rep_falta_atividades = []
    @average_curso_hrs_matriculado_regulares_eletivas = []
    @average_curso_hrs_matriculado_atividades = []
    @average_curso_num_rep_falta_regulares_eletivas = []
    @average_curso_num_trancado = []
    @average_curso_num_cancelado = []
    @average_curso_ratio_apr = []
    @average_curso_cr = []
    @average_curso_ira = []

    @average_geral_hrs_aproveitado_regulares_atividades = []
    @average_geral_hrs_apr_regulares_eletivas = []
    @average_geral_hrs_apr_atividades = []
    @average_geral_hrs_rep_media_regulares_eletivas = []
    @average_geral_hrs_rep_media_atividades = []
    @average_geral_hrs_rep_falta_regulares_eletivas = []
    @average_geral_hrs_rep_falta_atividades = []
    @average_geral_hrs_matriculado_regulares_eletivas = []
    @average_geral_hrs_matriculado_atividades = []
    @average_geral_num_rep_falta_regulares_eletivas = []
    @average_geral_num_trancado = []
    @average_geral_num_cancelado = []
    @average_geral_ratio_apr = []
    @average_geral_cr = []
    @average_geral_ira = []
  end

  def csv_analysis(csv)
    @forged_id = @data_nascimento.last(2) + @cpf.first(3) + @curriculo.first(5) + @matricula[6..7]
    @unique_ano_per = csv["ano_per"].uniq.sort
    @unique_ano_per.each do |ano_per|
      csv_ano_per = csv.select { |row| row["ano_per"] == ano_per }

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

      @hrs_aproveitado_regulares << aproveitado_regulares.sum(0) { |row| row["ch"].to_i }
      @hrs_aproveitado_atividades << aproveitado_atividades.sum(0) { |row| row["ch"].to_i }

      hrs_apr_regulares = apr_regulares.sum(0) { |row| row["ch"].to_i }
      hrs_apr_eletivas = apr_eletivas.sum(0) { |row| row["ch"].to_i }
      hrs_apr_regulares_eletivas = hrs_apr_regulares + hrs_apr_eletivas
      @hrs_apr_regulares << hrs_apr_regulares
      @hrs_apr_eletivas << hrs_apr_eletivas
      @hrs_apr_regulares_eletivas << hrs_apr_regulares_eletivas

      @hrs_apr_atividades << apr_atividades.sum(0) { |row| row["ch"].to_i }

      hrs_rep_media_regulares_eletivas = rep_media_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_media_regulares_eletivas << hrs_rep_media_regulares_eletivas
      @hrs_rep_media_atividades << rep_media_atividades.sum(0) { |row| row["ch"].to_i }

      hrs_rep_falta_regulares_eletivas = rep_falta_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_rep_falta_regulares_eletivas << hrs_rep_falta_regulares_eletivas
      @hrs_rep_falta_atividades << rep_falta_atividades.sum(0) { |row| row["ch"].to_i }

      hrs_cursado_regulares_eletivas = hrs_apr_regulares_eletivas + hrs_rep_media_regulares_eletivas + hrs_rep_falta_regulares_eletivas
      @hrs_cursado_regulares_eletivas << hrs_cursado_regulares_eletivas

      @hrs_matriculado_regulares << matriculado_regulares.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_eletivas << matriculado_eletivas.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_atividades << matriculado_atividades.sum(0) { |row| row["ch"].to_i }
      @hrs_matriculado_regulares_eletivas = @hrs_matriculado_regulares + @hrs_matriculado_eletivas

      @num_rep_falta_regulares_eletivas << rep_falta_regulares_eletivas.size
      @num_trancado << trancado.size
      @num_cancelado << cancelado.size

      csv_analysis_ratio_apr(hrs_apr_regulares_eletivas, hrs_cursado_regulares_eletivas)
      csv_analysis_cr_ira(csv, ano_per, csv_ano_per, situacoes_rep_falta)
      csv_analysis_contrapartida_proaes()
      save_attendance(ano_per)
      averages_curso(ano_per)
      averages_geral(ano_per)
      @unique_ano_per[0] = "0000.0" if @unique_ano_per[0] == "--"
    end
  end

  def csv_analysis_ratio_apr(hrs_apr_regulares_eletivas, hrs_cursado_regulares_eletivas)
    ratio_apr = hrs_cursado_regulares_eletivas == 0 ? 0 : ((hrs_apr_regulares_eletivas / hrs_cursado_regulares_eletivas).round(3))
    @ratio_apr << ratio_apr
  end

  def csv_analysis_cr_ira(csv, ano_per, csv_ano_per, situacoes_rep_falta)
    cr_rows = csv_ano_per.select { |row| numeric?(row["media"][0]) }
    ch_sum = cr_rows.sum(0.0) { |row| situacoes_rep_falta.include?(row["situacao"]) ? 0 : ((row["media"].gsub(",", ".").to_f) * row["ch"].to_f) }
    cr = cr_rows.empty? ? 0.0 : (ch_sum / (cr_rows.sum(0) { |row| row["ch"].to_f })).round(2)
    @cr << cr

    ira_rows = csv.select { |row| numeric?(row["media"][0]) && row["ano_per"] <= ano_per }
    ch_sum = ira_rows.sum(0.0) { |row| situacoes_rep_falta.include?(row["situacao"]) ? 0 : ((row["media"].gsub(",", ".").to_f) * row["ch"].to_f) }
    ira = ira_rows.empty? ? 0.0 : (ch_sum / (ira_rows.sum(0) { |row| row["ch"].to_f })).round(2)
    @ira << ira
  end

  def csv_analysis_contrapartida_proaes()

    # transpor lógica do vba

    @contrapartida_resultado
    @contrapartida_motivo

  end

  def save_attendance(ano_per)
    ano_per = "0000.0" if ano_per = "--"
    attendance_saved = Attendance.find_by(forged_id: forged_id, ano_per: ano_per)
    unless attendance_saved
      attendance = Attendance.new
      attendance.forged_id = @forged_id
      attendance.curso = @curso.last
      attendance.curriculo = @curriculo.last
      attendance.exigido = @exigido.last
      attendance.turno = @turno.last
      attendance.inicio = @inicio.last
      attendance.ano_per = ano_per
      attendance.hrs_aproveitado_regulares = @hrs_aproveitado_regulares.last
      attendance.hrs_aproveitado_atividades = @hrs_aproveitado_atividades.last
      attendance.hrs_apr_regulares = @hrs_apr_regulares.last
      attendance.hrs_apr_eletivas = @hrs_apr_eletivas.last
      attendance.hrs_apr_atividades = @hrs_apr_atividades.last
      attendance.hrs_rep_media_regulares_eletivas = @hrs_rep_media_regulares_eletivas.last
      attendance.hrs_rep_media_atividades = @hrs_rep_media_atividades.last
      attendance.hrs_rep_falta_regulares_eletivas = @hrs_rep_falta_regulares_eletivas.last
      attendance.hrs_rep_falta_atividades = @hrs_rep_falta_atividades.last
      attendance.hrs_cursado_regulares_eletivas = @hrs_cursado_regulares_eletivas.last
      attendance.hrs_matriculado_regulares = @hrs_matriculado_regulares.last
      attendance.hrs_matriculado_eletivas = @hrs_matriculado_eletivas.last
      attendance.hrs_matriculado_atividades = @hrs_matriculado_atividades.last
      attendance.num_rep_falta_regulares_eletivas = @num_rep_falta_regulares_eletivas.last
      attendance.num_trancado = @num_trancado.last
      attendance.num_cancelado = @num_cancelado.last
      attendance.ratio_apr = @ratio_apr.last
      attendance.cr = @cr.last
      attendance.ira = @ira.last
      attendance.contrapartida_resultado = @contrapartida_resultado.last
      attendance.contrapartida_motivo = @contrapartida_motivo.last
      attendance.save!
    end
  end

  def averages_curso(ano_per)
    attendances_curso = Attendance.where(ano_per: ano_per, curso: @curso)
    attendances_curso_cursado = Attendance.where(ano_per: ano_per, curso: @curso, "hrs_cursado_regulares_eletivas > ?", 0)

    # completar com queries pelo rails

    @average_curso_hrs_aproveitado_regulares_atividades <<
    @average_curso_hrs_apr_regulares_eletivas <<
    @average_curso_hrs_apr_atividades << attendances_curso.average(:hrs_apr_atividades).round
    @average_curso_hrs_rep_media_regulares_eletivas << attendances_curso.average(:hrs_rep_media_regulares_eletivas).round
    @average_curso_hrs_rep_media_atividades << attendances_curso.average(:hrs_rep_media_atividades).round
    @average_curso_hrs_rep_falta_regulares_eletivas << attendances_curso.average(:hrs_rep_falta_regulares_eletivas).round
    @average_curso_hrs_rep_falta_atividades << attendances_curso.average(:hrs_rep_falta_atividades).round
    @average_curso_hrs_matriculado_regulares_eletivas <<
    @average_curso_hrs_matriculado_atividades << attendances_curso.average(:hrs_matriculado_atividades).round
    @average_curso_num_rep_falta_regulares_eletivas << attendances_curso.average(:num_rep_falta_regulares_eletivas).round
    @average_curso_num_trancado << attendances_curso.average(:num_trancado).round
    @average_curso_num_cancelado << attendances_curso.average(:num_cancelado).round
    @average_curso_ratio_apr << attendances_curso_cursado.average(:ratio_apr).round(3)
    @average_curso_cr << attendances_curso_cursado.average(:cr).round(2)
    @average_curso_ira << attendances_curso.average(:ira).round(2)
  end

  def averages_geral(ano_per)
    attendances_geral = Attendance.where(ano_per: ano_per)
    attendances_geral_cursado = Attendance.where(ano_per: ano_per, "hrs_cursado_regulares_eletivas > ?", 0)

    # completar com queries pelo rails

    @average_geral_hrs_aproveitado_regulares_atividades <<
    @average_geral_hrs_apr_regulares_eletivas <<
    @average_geral_hrs_apr_atividades << attendances_geral.average(:hrs_apr_atividades).round
    @average_geral_hrs_rep_media_regulares_eletivas << attendances_geral.average(:hrs_rep_media_regulares_eletivas).round
    @average_geral_hrs_rep_media_atividades << attendances_geral.average(:hrs_rep_media_atividades).round
    @average_geral_hrs_rep_falta_regulares_eletivas << attendances_geral.average(:hrs_rep_falta_regulares_eletivas).round
    @average_geral_hrs_rep_falta_atividades << attendances_geral.average(:hrs_rep_falta_atividades).round
    @average_geral_hrs_matriculado_regulares_eletivas <<
    @average_geral_hrs_matriculado_atividades << attendances_geral.average(:hrs_matriculado_atividades).round
    @average_geral_num_rep_falta_regulares_eletivas << attendances_geral.average(:num_rep_falta_regulares_eletivas).round
    @average_geral_num_trancado << attendances_geral.average(:num_trancado).round
    @average_geral_num_cancelado << attendances_geral.average(:num_cancelado).round
    @average_geral_ratio_apr << attendances_geral_cursado.average(:ratio_apr).round(3)
    @average_geral_cr << attendances_geral_cursado.average(:cr).round(2)
    @average_geral_ira << attendances_geral.average(:ira).round(2)
  end

  def geral_summaries


    averages_curso_geral
    averages_geral_geral
  end

  def averages_curso_geral


  end

  def averages_geral_geral


  end
end
