class SlidingPieces < Piece
  def initialize(position, board, color)
    super
  end

  def moves(direction_array)
    results = []
    direction_array.each do |direction|
      x, y = position[0] + direction[0], position[1] + direction[1]
      pos = [x, y]
      while within_grid?([x, y])
        break if team_piece?(pos)
        results << [x, y]
        break if opponent_piece?(pos)
        x, y = x + direction[0], y + direction[1]
      end
    end
    results
  end

end
