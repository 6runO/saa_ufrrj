require 'pdf-reader'
require 'csv'

class Historico
  attr_reader :nome, :matricula, :data_nascimento, :local_nascimento, :cpf, :curriculo, :inicio, :ingresso

  def parse_pdf(pdf_path, csv_path)
    #### Doing stuff with pdf-reader
    reader = PDF::Reader.new(pdf_path)
    csv_options = { col_sep: ',', force_quotes: true, quote_char: '"' }
    CSV.open(csv_path, "wb", csv_options) do |csv|
      #### Headers
      csv << %w(ano_per tipo componente ch turma freq media situacao)
      loop_through_pages(reader, csv)
    end
    collect_student_info_by_line(reader)
    collect_student_info_by_page(reader)
    collect_exigido(reader, @table_page)
  end

  def pdf_is_historico?(pdf_path)
    reader = PDF::Reader.new(pdf_path)
    page = reader.page(1)
    page_text = page.text
    #### Uncomment only for code checking purposes
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

  def loop_through_lines(page, csv, index)
    page.text.each_line do |line|
      (@table_page = index + 1) if (line.include? "Carga Horária Integralizada/Pendente")
      data = line.split
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
      #### Uncomment only for code checking purposes
      # puts page.text if (index == 0)
      loop_through_lines(page, csv, index)
    end
  end

  def collect_student_info_by_line(reader)
    page_one = reader.page(1).text
    page_one.each_line do |line|
      line_array = line.split
      (@nome = line_array[(line_array.index("Nome:") + 1)..(line_array.index("Matrícula:") - 1)].join(' ')) if line["Nome:"]
      (@matricula = line_array[line_array.index("Matrícula:") + 1]) if line["Matrícula:"]
      (@data_nascimento = line_array[line_array.index("Nascimento:") + 1]) if line["Data de Nascimento:"]
      (@cpf = line_array[line_array.index("CPF:") + 1]) if line["Nº do CPF:"]
      (@curriculo = line_array[(line_array.index("Currículo:") + 1)..(line_array.index("Currículo:") + 3)].join(' ')) if line["Currículo:"]
      (@inicio = line_array[line_array.index("Inicial:") + 1]) if line["Período Letivo Inicial:"]
      # (@local_nascimento = line_array[(line_array.index("Local") + 3)..-1].join(' ')) if line["Local de Nascimento:"]
      # (@ingresso = line_array[3..-1].join(' ')) if line["Forma de Ingresso:"]
    end
  end

  def collect_student_info_by_page(reader)
    page_one = reader.page(1).text
    curso = page_one[(page_one.index('Dados do Vínculo do Discente') + 28)..(page_one.index('Status:') - 1)]
    curso.slice!("Curso:")
    curso = curso.split
    @turno = curso[-1]
    @curso = curso.join(' ')
  end

  def collect_exigido(reader, table_page)
    page = reader.page(table_page).text
    find_string = "Carga Horária Integralizada/Pendente"
    look_for_from = page.index(find_string) + find_string.length
    start_from = page.index("Exigido", look_for_from)
    if start_from
      start_from += 7
    else
      page = reader.page(table_page + 1).text
      start_from = page.index("Exigido", look_for_from) + 7
    end
    exigido = page[start_from..(start_from + 100)]
    exigido.slice!("h")
    exigido = exigido.split
    @exigido = exigido[0].to_i + exigido[1].to_i
  end
end
