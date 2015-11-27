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

    @pieces = pieces
  end

  def move(piece)
    piece.pos = valid_moves(piece)[rand(valid_moves(piece).length)]
    piece.moves = piece.find_moves
    display
  end

  def valid_moves(piece)
    piece.moves.select do |move|
      move.all? do |coord|
        coord >= 0 && coord < dim
      end
    end
  end

  def display
    puts
    puts display_string
  end

  def display_string
    display_rows = rows.map do |row|
      row.map do |square|
        square
      end
    end

    pieces.each do |piece|
      display_rows[piece.pos[0]][piece.pos[1]] = piece
    end

    display_rows.map do |row|
      row.map do |square|
        if square.is_a?(Knight)
          square.mark
        else
          if square.even?
            "  "
          else
            "@@"
          end
        end
      end.join("").center(line_width)
    end.join("\n")
  end

  private

  attr_reader :dim, :line_width
  attr_accessor :rows
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
    @move_patterns.map do |pattern|
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
  puts "You made it in #{moves.length - 1} moves!"
  moves.each { |move| p move }
  puts
end

board = Board.new([Knight.new([4, 4])])
puts board.display
board.move(board.pieces.first)
board.move(board.pieces.first)
board.move(board.pieces.first)
board.move(board.pieces.first)
puts
knight_moves([0, 1], [4, 3])
knight_moves([7, 7], [2, 3])
knight_moves([3, 3], [3, 3])
