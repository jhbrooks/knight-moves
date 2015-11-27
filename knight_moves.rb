#!/Users/jhbrooks/.rvm/rubies/ruby-2.2.0/bin/ruby

# This class describes a chess board
class Board
  attr_reader :pieces

  def initialize(pieces)
    @dim = 8
    @line_width = 80
    @rows = []
    dim.times do |row_n|
      rows << []
      dim.times do |col_n|
        rows[-1] << (row_n + col_n)
      end
    end

    @pieces = pieces.select do |piece|
      piece.pos.all? do |coord|
        coord >= 0 && coord < dim
      end
    end
  end

  def move(a, b)
    puts
    puts "Trying to move from #{a.inspect} to #{b.inspect}.".center(line_width)
    relevant_pieces = pieces.select { |piece| piece.pos == a }
    if relevant_pieces.empty?
      puts "No piece to move in #{a.inspect}.".center(line_width)
    else
      chosen_piece = relevant_pieces.last

      if valid_moves(chosen_piece).include?(b)
        chosen_piece.pos = b
        chosen_piece.moves = chosen_piece.find_moves
        puts "Moved from #{a.inspect} to #{b.inspect}.".center(line_width)
      else
        puts "#{a.inspect} to #{b.inspect} "\
             "is an invalid move.".center(line_width)
      end
    end

    display
  end

  def valid_moves(piece)
    piece.moves.select do |move|
      on_board?(move) && unoccupied?(move)
    end
  end

  def on_board?(move)
    move.all? do |coord|
      coord >= 0 && coord < dim
    end
  end

  def unoccupied?(move)
    pieces.none? { |piece| piece.pos == move }
  end

  def display
    puts
    puts display_string
  end

  private

  attr_reader :dim, :line_width
  attr_accessor :rows

  def display_string
    rows_with_pieces = copy_rows
    pieces.each do |piece|
      rows_with_pieces[piece.pos[0]][piece.pos[1]] = piece
    end

    rows_with_pieces.map do |row|
      row_string_with_label(row)
    end.unshift(top_label_string).join("\n")
  end

  def copy_rows
    rows.map do |row|
      row.map do |square|
        square
      end
    end
  end

  def row_string_with_label(row)
    adjustment = (line_width / 2) + (row_string(row).length / 2)
    "#{row.first} #{row_string(row)}".rjust(adjustment)
  end

  def row_string(row)
    row.map do |square|
      square_string(square)
    end.join("")
  end

  def square_string(square)
    if square.is_a?(Knight)
      square.mark
    else
      if square.even?
        "  "
      else
        "@@"
      end
    end
  end

  def top_label_string
    top_label_array = []
    dim.times do |n|
      top_label_array << "#{n} "
    end
    top_label_array.join("").center(line_width)
  end
end

# This class describes the knight piece
class Knight
  attr_reader :mark
  attr_accessor :pos, :moves

  def initialize(pos)
    @mark = "KN"
    @move_patterns = [[1, 2], [1, -2], [-1, 2], [-1, -2],
                      [2, 1], [2, -1], [-2, 1], [-2, -1]]

    @pos = pos
    @moves = find_moves
  end

  def find_moves
    move_patterns.map do |pattern|
      [pos[0] + pattern[0], pos[1] + pattern[1]]
    end
  end

  private

  attr_reader :move_patterns
end

# This class handles searching for knight moves
class Node
  def initialize(parent, board)
    @parent = parent
    @board = board
  end

  def knight_moves_bfs(targ, queue = [self])
    if board.pieces.first.pos == targ
      return [board.pieces.first.pos] if parent.nil?
      parent.build_path([board.pieces.first.pos])
    else
      queue.shift

      board.valid_moves(board.pieces.first).each do |move|
        queue.push(Node.new(self, Board.new([Knight.new(move)])))
      end

      queue.first.knight_moves_bfs(targ, queue)
    end
  end

  def build_path(path)
    path.unshift(board.pieces.first.pos)
    return path if parent.nil?
    parent.build_path(path)
  end

  private

  attr_reader :parent, :board
end

def knight_moves(a, b)
  moves = Node.new(nil, Board.new([Knight.new(a)])).knight_moves_bfs(b)
  puts "You can get from #{a.inspect} to #{b.inspect} "\
       "in #{moves.length - 1} moves!"
  moves.each { |move| p move }
  puts
end

board = Board.new([Knight.new([4, 4]), Knight.new([3, 7])])
puts board.display
board.move([4, 4], [2, 5])
board.move([4, 4], [2, 5])
board.move([2, 5], [4, 3])
board.move([2, 5], [3, 7])
board.move([3, 7], [5, 8])
board.move([2, 5], [4, 4])
puts
knight_moves([0, 1], [4, 3])
knight_moves([7, 7], [2, 3])
knight_moves([3, 3], [3, 3])
