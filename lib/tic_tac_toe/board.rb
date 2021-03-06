require 'forwardable'

class Board
  extend Forwardable
  BOARD_MAPPINGS = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
                    "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  attr_reader :width, :height, :board
  attr_writer :board
  def initialize(width, height)
    @width = width
    @height = height
    @board = Hash.new
    init_board
  end

  def end_state?
    WinChecker.call(self)
  end

  def available_tiles
    unmarked = []
    unmarked = board.reject {|coord, space|
      marked?(coord)
    }.map {|coord, space| coord.to_s}
  end

  def mark(coordinate, symbol)
    valid_coordinate?(coordinate)
    raise GameErrors::InvalidActionError if marked?(coordinate)
    set_location_symbol(coordinate.to_sym, symbol)
  end

  def marked?(coordinate)
    board[coordinate.to_sym] != " "
  end

  def get(coordinate)
    valid_coordinate?(coordinate)
    get_location_symbol(coordinate)
  end

  def display
    DisplayBoard.call(self)
  end

  def corners
    get_corner_coordinates
  end

  """
  This method will return an array of the values for
  each column in each row.
  """
  def get_rows
    rows = []
    row_names = get_row_names
    row_names.each do |row_name|
      rows << column_iterator(row_name)
    end
    rows
  end

  def get_columns
    columns = []
    col_num = 1
    height.times do
      columns << row_iterator(col_num)
      col_num += 1
    end
    columns
  end

  def get_left_diagonal
    diagonal = []
    start = width
    get_row_names.each do |row_name|
      diagonal << get_location_symbol(get_location_name(row_name,start))
      start -= 1
    end
    diagonal
  end

  def get_right_diagonal
    diagonal = []
    start = 1
    get_row_names.each do |row_name|
      diagonal << get_location_symbol(get_location_name(row_name,start))
      start += 1
    end
    diagonal
  end

  def_delegators :@board, :[], :[]=
  private
  def valid_coordinate?(coord)
    col = valid_column_name?(coord)
    row = valid_row_name?(coord)
    raise GameErrors::InvalidCoordinateError unless valid_board_coord?(row, col)
  end

  def valid_board_coord?(row, col)
    height > BOARD_MAPPINGS.index(row) && width >= col
  end

  def valid_column_name?(coord)
    column = coord.scan(/\d+\Z/).first
    raise GameErrors::InvalidCoordinateError if column.nil?
    Integer(column)
  end

  def valid_row_name?(coord)
    row = coord.scan(/\A[a-z]+/).first
    raise GameErrors::InvalidCoordinateError if row.nil?
    raise GameErrors::InvalidCoordinateError unless BOARD_MAPPINGS.include?(row)
    row
  end

  def get_corner_coordinates
    corners = []
    row_names = get_row_names
    first_col = 1
    last_col = width
    corners << "#{row_names.first}#{first_col}"
    corners << "#{row_names.first}#{last_col}"
    corners << "#{row_names.last}#{first_col}"
    corners << "#{row_names.last}#{last_col}"
    corners
  end

  def get_location_name(row_name, col_num)
    "#{row_name}#{col_num}".to_sym
  end

  def get_row_names
    board.keys.map {|c| c[0]}.join.squeeze.chars
  end

  def set_location_symbol(location, symbol)
    board[location.to_sym] = symbol
  end

  def get_location_symbol(location)
    board.fetch(location.to_sym)
  end

  def init_board
    row_index = 0
    column_index = 1
    @height.times do
      @width.times do
        key = ""
        key << BOARD_MAPPINGS[row_index] << column_index.to_s
        @board[key.to_sym] = " "
        column_index += 1
      end
      row_index += 1
      column_index = 1
    end
  end

  def row_iterator(col_num)
    column = []
    get_row_names.each do |row|
      column << get_location_symbol(get_location_name(row, col_num))
    end
    column
  end

  # iterates over current rows columns and returns the values
  def column_iterator(row_name)
    col_count = 1
    row = []
    width.times do
      row << get_location_symbol(get_location_name(row_name, col_count))
      col_count += 1
    end
    row
  end

  def initialize_copy(orig)
    super
    @board = @board.dup
  end
end
