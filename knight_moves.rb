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
    puts "Trying to move from #{a.inspect} to #{b.inspect}.".center(line_width)
    if pieces_at(a).empty?
      puts "No piece to move in #{a.inspect}.".center(line_width)
    else
      chosen_piece = pieces_at(a).last

      if valid_moves(chosen_piece).include?(b)
        chosen_piece.pos = b
        chosen_piece.moves = chosen_piece.find_moves
        puts "Moved from #{a.inspect} to #{b.inspect}.".center(line_width)
      else
        puts "#{a.inspect} to #{b.inspect} "\
             "is an invalid move.".center(line_width)
      end
    end
    puts

    display
  end

  def pieces_at(pos)
    pieces.select { |piece| piece.pos == pos }
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

  def knight_moves(a, b)
    new_ps = self.pieces.map { |piece| piece } << Knight.new(a)
    moves = Node.new(nil, Board.new(new_ps)).knight_moves_bfs(a, b)
    if moves.empty?
      puts "A knight can't get from #{a.inspect} to #{b.inspect} right now!"
      puts
    else
      puts "You can get from #{a.inspect} to #{b.inspect} "\
           "in #{moves.length - 1} moves!"
      moves.each { |move| p move }
      puts
    end
  end

  def display
    puts display_string
    puts
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
  attr_reader :board

  def initialize(parent, board)
    @parent = parent
    @board = board
  end

  def knight_moves_bfs(a, b, searched = [], queue = [self])
    if board.pieces_at(a).last.pos == b
      return [board.pieces_at(a).last.pos] if parent.nil?
      parent.build_path([board.pieces_at(a).last.pos])
    else
      searched << (board.pieces_at(a).last.pos)
      queue.shift

      board.valid_moves(board.pieces_at(a).last).each do |move|
        unless searched.include?(move)
          new_ps = board.pieces - [board.pieces_at(a).last] << Knight.new(move)
          queue.push(Node.new(self, Board.new(new_ps)))
        end
      end

      return [] if queue.empty?

      new_a = queue.first.board.pieces.last.pos
      queue.first.knight_moves_bfs(new_a, b, searched, queue)
    end
  end

  def build_path(path)
    path.unshift(board.pieces.last.pos)
    return path if parent.nil?
    parent.build_path(path)
  end

  private

  attr_reader :parent
end

board = Board.new([Knight.new([4, 4]), Knight.new([3, 7])])
puts
board.display
board.move([4, 4], [2, 5])
board.move([4, 4], [2, 5])
board.move([2, 5], [4, 3])
board.move([2, 5], [3, 7])
board.move([3, 7], [5, 8])
board.move([2, 5], [4, 4])

km_board = Board.new([Knight.new([1, 2]), Knight.new([2, 1])])
km_board.knight_moves([0, 0], [4, 3])
km_board.move([1, 2], [3, 3])
board.knight_moves([0, 0], [4, 3])
board.knight_moves([7, 7], [2, 1])
