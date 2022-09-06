require_relative "../models/historico"
require_relative "../models/contrapartida"
require 'tempfile'
require 'csv'

class PagesController < ApplicationController
  include Contrapartida

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
      indexes_names
      indexes_values
      indexes_averages
      save_curriculo
      csv_analysis(csv)
      ##### Uncomment when queries are built #####
      # geral_summaries
    end
    temp.unlink
  end

  def indexes_names
    #### :variable => "Label"
    @gerais_names = {cr: "CR", ira: "IRA", ratio_apr: "% APR"}
    @contrapartida_names = {hrs_apr_regulares_eletivas: "Hrs APR",
      hrs_rep_media_regulares_eletivas: "Hrs REP", hrs_rep_falta_regulares_eletivas: "Hrs REPF",
      num_rep_falta_regulares_eletivas: "Nº REPF"}
  end

  def indexes_values
    #### :variable => [array]
    @gerais_values = @gerais_names.transform_values {[]}
    @contrapartida_values = @contrapartida_names.transform_values {[]}
    @pontuais_values = {hrs_aproveitado_regulares: [], hrs_aproveitado_atividades: [],
      hrs_apr_regulares: [], hrs_apr_eletivas: [],
      hrs_apr_atividades: [], hrs_rep_media_atividades: [],
      hrs_rep_falta_atividades: [], hrs_matriculado_regulares: [],
      hrs_matriculado_eletivas: [], hrs_matriculado_atividades: [],
      num_cancelado: [], mat_trancada: [], mat_cancelada: [],
      num_trancado: [], num_matriculado: [], nenhuma_situação: []}
    @hrs_cursado_regulares_eletivas = []
    @contrapartida_resultado = []
    @contrapartida_motivo = []
  end

  def indexes_averages
    @curso_gerais_averages = @gerais_names.transform_values {[]}
    @curso_contrapartida_averages = @contrapartida_names.transform_values {[]}
    @geral_gerais_averages = @gerais_names.transform_values {[]}
    @geral_contrapartida_averages = @contrapartida_names.transform_values {[]}
  end

  def save_curriculo
    @curriculo = Curriculo.find_by(codigo: @h.curriculo_codigo)
    unless @curriculo
      @curriculo = Curriculo.new
      @curriculo.codigo = @h.curriculo_codigo
      @curriculo.periodo = @h.curriculo_periodo
      @curriculo.curso = @h.curso
      @curriculo.exigido = @h.exigido
      @curriculo.turno = @h.turno
      @curriculo.save!
    end
  end

  def csv_analysis(csv)
    @unique_ano_per = csv["ano_per"].uniq.sort
    @unique_ano_per.each do |ano_per|
      csv_ano_per = csv.select { |row| row["ano_per"] == ano_per }

      #### As situações matriculado, trancado e cancelado não precisam de array, pois só possuem um item
      situacoes_aproveitado = ["CUMPRIU", "TRANSFERIDO", "INCORPORADO", "DISPENSADO"]
      situacoes_apr = ["APR", "APRN"]
      situacoes_rep_media = ["REP", "REPN"]
      situacoes_rep_falta = ["REPF", "REPMF", "REPNF"]

      #### O tipo eletivo não precisa de array, pois só possui um item
      tipos_regulares = ["", "*", "e", "&"]
      tipos_atividades = ["@", "§"]

      #### Filtering csv data
      aproveitado_geral = csv_ano_per.select { |row| situacoes_aproveitado.include?(row['situacao']) }
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
      matriculado_num_total = csv_ano_per.select { |row| row["situacao"] == "MATRICULADO" }
      trancado = csv_ano_per.select { |row| row["situacao"] == "TRANCADO" }
      cancelado = csv_ano_per.select { |row| row["situacao"] == "CANCELADO" }
      nenhuma_situação = csv_ano_per.select { |row| row["situacao"] == "--" }

      #### Pontuais values
      @pontuais_values[:hrs_aproveitado_regulares] << aproveitado_regulares.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_aproveitado_atividades] << aproveitado_atividades.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_apr_regulares] << apr_regulares.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_apr_eletivas] << apr_eletivas.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_apr_atividades] << apr_atividades.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_rep_media_atividades] << rep_media_atividades.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_rep_falta_atividades] << rep_falta_atividades.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_matriculado_regulares] << matriculado_regulares.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_matriculado_eletivas] << matriculado_eletivas.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:hrs_matriculado_atividades] << matriculado_atividades.sum(0) { |row| row["ch"].to_i }
      @pontuais_values[:num_cancelado] << cancelado.size
      @pontuais_values[:mat_trancada] << ((csv_ano_per.size - aproveitado_geral.size) == trancado.size)
      @pontuais_values[:mat_cancelada] << ((csv_ano_per.size - aproveitado_geral.size) == cancelado.size)
      @pontuais_values[:num_trancado] << trancado.size
      @pontuais_values[:num_matriculado] << matriculado_num_total.count
      @pontuais_values[:nenhuma_situação] << csv_ano_per.size == nenhuma_situação.size

      #### Contrapartida values
      @contrapartida_values[:hrs_apr_regulares_eletivas] << @pontuais_values[:hrs_apr_regulares].last +
      @pontuais_values[:hrs_apr_eletivas].last
      @contrapartida_values[:hrs_rep_media_regulares_eletivas] << rep_media_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @contrapartida_values[:hrs_rep_falta_regulares_eletivas] << rep_falta_regulares_eletivas.sum(0) { |row| row["ch"].to_i }
      @contrapartida_values[:num_rep_falta_regulares_eletivas] << rep_falta_regulares_eletivas.size

      #### Other variables needed
      hrs_apr_regulares_eletivas = @contrapartida_values[:hrs_apr_regulares_eletivas].last
      @hrs_cursado_regulares_eletivas << @contrapartida_values[:hrs_apr_regulares_eletivas].last +
        @contrapartida_values[:hrs_rep_media_regulares_eletivas].last +
        @contrapartida_values[:hrs_rep_falta_regulares_eletivas].last

      csv_analysis_ratio_apr(hrs_apr_regulares_eletivas, @hrs_cursado_regulares_eletivas.last)
      csv_analysis_cr_ira(csv, ano_per, csv_ano_per, situacoes_rep_falta)
      csv_analysis_contrapartida
      save_cursado(ano_per)
      ##### Uncomment when queries are built #####
      averages_curso(ano_per)
      # averages_geral(ano_per)
    end
    @gerais_values[:ratio_apr].map! do |ratio|
      (ratio * 100).round.to_s + "%"
    end
  end

  def csv_analysis_ratio_apr(hrs_apr_regulares_eletivas, hrs_cursado_regulares_eletivas)
    ratio_apr = hrs_cursado_regulares_eletivas == 0 ? 0 : ((hrs_apr_regulares_eletivas.to_f / hrs_cursado_regulares_eletivas.to_f).round(3))
    @gerais_values[:ratio_apr] << ratio_apr
  end

  def csv_analysis_cr_ira(csv, ano_per, csv_ano_per, situacoes_rep_falta)
    cr_rows = csv_ano_per.select { |row| numeric?(row["media"][0]) }
    ch_sum = cr_rows.sum(0.0) { |row| situacoes_rep_falta.include?(row["situacao"]) ? 0 : ((row["media"].gsub(",", ".").to_f) * row["ch"].to_f) }
    cr = cr_rows.empty? ? 0.0 : (ch_sum / (cr_rows.sum(0) { |row| row["ch"].to_f })).round(2)
    @gerais_values[:cr] << cr

    ira_rows = csv.select { |row| numeric?(row["media"][0]) && row["ano_per"] <= ano_per }
    ch_sum = ira_rows.sum(0.0) { |row| situacoes_rep_falta.include?(row["situacao"]) ? 0 : ((row["media"].gsub(",", ".").to_f) * row["ch"].to_f) }
    ira = ira_rows.empty? ? 0.0 : (ch_sum / (ira_rows.sum(0) { |row| row["ch"].to_f })).round(2)
    @gerais_values[:ira] << ira
  end

  def csv_analysis_contrapartida
    @contrapartida_motivo << contrapartida_motivo(
      num_repf: @contrapartida_values[:num_rep_falta_regulares_eletivas].last,
      hrs_apr: @contrapartida_values[:hrs_apr_regulares_eletivas].last,
      hrs_repm: @contrapartida_values[:hrs_rep_media_regulares_eletivas].last,
      hrs_repf: @contrapartida_values[:hrs_rep_falta_regulares_eletivas].last,
      ratio_apr: @gerais_values[:ratio_apr].last, cr: @gerais_values[:cr].last,
      ira: @gerais_values[:ira].last, num_matriculado: @pontuais_values[:num_matriculado].last,
      ch_min: @h.ch_min, hrs_matriculado_regulares: @pontuais_values[:hrs_matriculado_regulares].last,
      hrs_matriculado_eletivas: @pontuais_values[:hrs_matriculado_eletivas].last)
    @contrapartida_resultado << contrapartida_resultado(@contrapartida_motivo.last)
  end

  def save_cursado(ano_per)
    cursado = Cursado.find_by(matricula: @h.matricula, periodo: ano_per)
    unless cursado || @pontuais_values[:num_matriculado].last > 0 || @pontuais_values[:nenhuma_situação].last
      new_cursado = Cursado.new
      new_cursado.matricula = @h.matricula
      new_cursado.periodo = ano_per
      new_cursado.save!
      save_periodo(ano_per)
    end
  end

  def save_periodo(ano_per)
    periodo = Periodo.new
    periodo.curriculo = @curriculo
    periodo.ano_per = ano_per
    periodo.inicio_curso = @h.inicio
    periodo.hrs_aproveitado_regulares = @pontuais_values[:hrs_aproveitado_regulares].last
    periodo.hrs_aproveitado_atividades = @pontuais_values[:hrs_aproveitado_atividades].last
    periodo.hrs_apr_regulares = @pontuais_values[:hrs_apr_regulares].last
    periodo.hrs_apr_eletivas = @pontuais_values[:hrs_apr_eletivas].last
    periodo.hrs_apr_atividades = @pontuais_values[:hrs_apr_atividades].last
    periodo.hrs_rep_media_regulares_eletivas = @contrapartida_values[:hrs_rep_media_regulares_eletivas].last
    periodo.hrs_rep_media_atividades = @pontuais_values[:hrs_rep_media_atividades].last
    periodo.hrs_rep_falta_regulares_eletivas = @contrapartida_values[:hrs_rep_falta_regulares_eletivas].last
    periodo.hrs_rep_falta_atividades = @pontuais_values[:hrs_rep_falta_atividades].last
    periodo.num_rep_falta_regulares_eletivas = @contrapartida_values[:num_rep_falta_regulares_eletivas].last
    periodo.num_trancado = @pontuais_values[:num_trancado].last
    periodo.num_cancelado = @pontuais_values[:num_cancelado].last
    periodo.ratio_apr = @gerais_values[:ratio_apr].last
    periodo.cr = @gerais_values[:cr].last
    periodo.ira = @gerais_values[:ira].last
    periodo.save!
  end

  def averages_curso(ano_per)
    periodo_curso = Periodo.joins(:curriculo).where("periodos.ano_per" => ano_per, "curriculos.curso" => @curriculo.curso)
    # periodo_curso = Curriculo.connection.select_all <<-SQL.squish
    #     SELECT *
    #     FROM curriculos
    #     INNER JOIN periodos ON periodos.curriculo_id = curriculos.id
    #     WHERE periodos.ano_per = #{ano_per}
    #     AND curriculos.curso = #{@curriculo.curso}
    #   SQL

    periodo_cursado = periodo_curso.connection.select_all <<-SQL.squish
        SELECT *
        FROM curriculos
        INNER JOIN periodos ON periodos.curriculo_id = curriculos.id
        GROUP BY curriculos.id, periodos.id
        HAVING SUM(periodos.hrs_apr_regulares + periodos.hrs_apr_eletivas +
          periodos.hrs_rep_media_regulares_eletivas + periodos.hrs_rep_falta_regulares_eletivas) = 0
          AND periodos.ano_per = #{ano_per} AND curriculos.curso = #{@curriculo.curso}
      SQL
    ### Selecionar apenas hashes do ano_per
    periodo_cursado = periodo_cursado.to_a

    #### SQL Queries through rails
    if periodo_cursado.empty?
      @curso_gerais_averages[:cr] << "N/A"
      @curso_gerais_averages[:ira] << "N/A"
      @curso_gerais_averages[:ratio_apr] << "N/A"
    else
      @curso_gerais_averages[:cr] << (periodo_cursado.sum(0.0) {|c| c["cr"]} / periodo_cursado.size).round(2)
      @curso_gerais_averages[:ira] << (periodo_cursado.sum(0.0) {|c| c["ira"]} / periodo_cursado.size).round(2)
      ratio = (periodo_cursado.sum(0.0) {|c| c["ratio_apr"]} / periodo_cursado.size).round(3)
      ratio_formated = (ratio * 100).round.to_s + "%"
      @curso_gerais_averages[:ratio_apr] << ratio_formated
    end

    # if @pontuais_values[:mat_trancada].last or @pontuais_values[:mat_cancelada].last or @pontuais_values[:num_matriculado].last > 0
    if periodo_curso.empty?
      @curso_contrapartida_averages[:hrs_apr_regulares_eletivas] << "N/A"
      @curso_contrapartida_averages[:hrs_rep_media_regulares_eletivas] << "N/A"
      @curso_contrapartida_averages[:hrs_rep_falta_regulares_eletivas] << "N/A"
      @curso_contrapartida_averages[:num_rep_falta_regulares_eletivas] << "N/A"
    else
      @curso_contrapartida_averages[:hrs_apr_regulares_eletivas] << periodo_curso.average("hrs_apr_regulares_eletivas").round
      @curso_contrapartida_averages[:hrs_rep_media_regulares_eletivas] << periodo_curso.average("hrs_rep_media_regulares_eletivas").round
      @curso_contrapartida_averages[:hrs_rep_falta_regulares_eletivas] << periodo_curso.average("hrs_rep_falta_regulares_eletivas").round
      @curso_contrapartida_averages[:num_rep_falta_regulares_eletivas] << periodo_curso.average("num_rep_falta_regulares_eletivas").round
    end
  end

  def averages_geral(ano_per)
    periodo_geral = Curriculo.joins(:periodos).where("periodos.ano_per" => ano_per)
    # attendances_geral = Periodo.where(ano_per: ano_per)
    ### Review line below ###
    # attendances_geral_cursado = Periodo.where(ano_per: ano_per, "hrs_cursado_regulares_eletivas > ?", 0)

    # completar com queries pelo rails

    # @average_geral_hrs_aproveitado_regulares_atividades <<
    # @average_geral_hrs_apr_regulares_eletivas <<
    # @average_geral_hrs_apr_atividades << attendances_geral.average(:hrs_apr_atividades).round
    # @average_geral_hrs_rep_media_regulares_eletivas << attendances_geral.average(:hrs_rep_media_regulares_eletivas).round
    # @average_geral_hrs_rep_media_atividades << attendances_geral.average(:hrs_rep_media_atividades).round
    # @average_geral_hrs_rep_falta_regulares_eletivas << attendances_geral.average(:hrs_rep_falta_regulares_eletivas).round
    # @average_geral_hrs_rep_falta_atividades << attendances_geral.average(:hrs_rep_falta_atividades).round
    # @average_geral_hrs_matriculado_regulares_eletivas <<
    # @average_geral_hrs_matriculado_atividades << attendances_geral.average(:hrs_matriculado_atividades).round
    # @average_geral_num_rep_falta_regulares_eletivas << attendances_geral.average(:num_rep_falta_regulares_eletivas).round
    # @average_geral_num_trancado << attendances_geral.average(:num_trancado).round
    # @average_geral_num_cancelado << attendances_geral.average(:num_cancelado).round
    # @average_geral_ratio_apr << attendances_geral_cursado.average(:ratio_apr).round(3)
    # @average_geral_cr << attendances_geral_cursado.average(:cr).round(2)
    # @average_geral_ira << attendances_geral.average(:ira).round(2)
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
