require "tempfile"

# Класс для обработки и сортировки транзакций
class TransactionSorter
  def initialize(input_file, output_file, chunk_size = 100_000)
    @input_file = input_file
    @output_file = output_file
    @chunk_size = chunk_size
  end

  # Основной метод выполнения сортировки
  def process!
    temp_files = split_and_sort_chunks
    merge_sorted_chunks(temp_files)
  ensure
    temp_files.each(&:close!) if temp_files
  end

  private

  # Разбивает файл на чанки, сортирует их и записывает во временные файлы
  def split_and_sort_chunks
    temp_files = []
    transactions = []

    File.foreach(@input_file) do |line|
      transactions << Transaction.build_from_string(line)
      if transactions.size >= @chunk_size
        temp_files << write_sorted_chunk(transactions)
        transactions.clear
      end
    end

    temp_files << write_sorted_chunk(transactions) unless transactions.empty?
    temp_files
  end

  # Записывает отсортированный чанк во временный файл
  def write_sorted_chunk(transactions)
    transactions.sort_by! { |t| -t.amount } # Сортируем по убыванию
    temp_file = Tempfile.new('sorted_chunk')
    transactions.each { |t| temp_file.puts t.to_s }
    temp_file.rewind
    temp_file
  end

  # Сливает отсортированные чанки в выходной файл
  def merge_sorted_chunks(temp_files)
    files = temp_files.map { |file| file.open }
    sorted_enumerators = files.map { |file| Enumerator.new { |y| file.each_line { |line| y << Transaction.build_from_string(line) } } }
    File.open(@output_file, 'w') do |output|
      sorted_enum = merge_enumerators(sorted_enumerators)
      sorted_enum.compact.each { |transaction| output.puts transaction.to_s }
    end
  ensure
    files.each(&:close) if files
  end


  def merge_enumerators(enumerators)
    Enumerator.new do |yielder|
      # Инициализация кучи: берем первый элемент из каждого enumerator'а
      heap = []
      enumerators.each do |enum|
        begin
          heap << [enum.next, enum]  # Берём первый элемент, чтобы избежать дубликатов
        rescue StopIteration
          next # Если enum пуст, просто пропускаем его
        end
      end
      heap.sort_by! { |t| -t[0].amount } # Сортируем по убыванию amount

      while heap.any?
        transaction, enum = heap.shift
        yielder << transaction

        begin
          next_transaction = enum.next
          heap << [next_transaction, enum]
          heap.sort_by! { |t| -t[0].amount }
        rescue StopIteration
          # Если поток закончился — просто пропускаем его
        end
      end
    end
  end
end
