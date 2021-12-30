require 'pdf-reader'
require 'csv'

class Historico
  attr_reader :nome, :matricula, :data_nascimento, :local_nascimento, :cpf, :curriculo, :inicio, :ingresso

  # pdf_path = "../scrap/historico_20200038248.pdf"

  def parse_pdf(pdf_path, csv_path)
    # csv_path = Rails.root.join "app", "csv", "historico.csv"
    # Doing stuff with pdf-reader
    reader = PDF::Reader.new(pdf_path)
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
    CSV.open(csv_path, "wb", csv_options) do |csv|
      # Headers
      csv << %w(ano_per tipo componente ch turma freq media situacao)
      loop_through_pages(reader, csv)
    end
  end

  def pdf_is_historico?(pdf_path)
    reader = PDF::Reader.new(pdf_path)
    page = reader.page(1)
    page_text = page.text
    ### Uncomment only for code checking purposes
    # puts page_text
    text_check_one = "Histórico Escolar - Emitido em:"
    text_check_two = "Sistema Integrado de Gestão de Atividades Acadêmicas"
    page_text.include? text_check_one && text_check_two
  end

  private

  def numeric?(string)
    Float(string) != nil rescue false
  end

  def number_on_right_to_array(string)
    if numeric?(string.chars.last(3).join)
      return string.chars.last(3).join.split
    elsif numeric?(string.chars.last(2).join)
      return string.chars.last(2).join.split
    elsif numeric?(string.chars.last)
      return string.chars.last.split
    else
      return ["0"]
    end
  end

  def collect_student_info(line, line_array)
    (@nome = line_array[line_array.index("Nome:") + 1]) if line["Nome:"]
    (@matricula = line_array[line_array.index("Matrícula:") + 1]) if line["Matrícula:"]
    (@data_nascimento = line_array[line_array.index("Nascimento:") + 1]) if line["Data de Nascimento:"]
    (@local_nascimento = line_array[(line_array.index("Local") + 3)..-1].join(' ')) if line["Local de Nascimento:"]
    (@cpf = line_array[line_array.index("CPF:") + 1]) if line["Nº do CPF:"]
    (@curriculo = line_array[(line_array.index("Currículo:") + 1)..(line_array.index("Currículo:") + 3)].join(' ')) if line["Currículo:"]
    (@inicio = line_array[line_array.index("Inicial:") + 1]) if line["Período Letivo Inicial:"]
    (@ingresso = line_array[3..-1].join(' ')) if line["Forma de Ingresso:"]
  end

  def loop_through_lines(page, index, csv)
    page.text.each_line do |line|
      data = line.split
      # Collect student info if we are in pdf's first page
      collect_student_info(line, data) if (index == 0)
      first_word = data.first
      if numeric?(first_word) || first_word == "--"
        first_array = (data[1].length > 1) ? [first_word, "", data[1]] : data.first(3)
        middle_array = number_on_right_to_array(data[-5])
        last_array = data.last(4)
        csv << first_array + middle_array + last_array
      end
    end
  end

  def loop_through_pages(reader, csv)
    reader.pages.each_with_index do |page, index|
      ### Uncomment only for code checking purposes
      # puts page.text if (index == 0)
      loop_through_lines(page, index, csv)
    end
  end
end
