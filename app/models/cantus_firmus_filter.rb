class CantusFirmusFilter < ApplicationRecord
  def self.filter(movements, position, notes)
    @position = position
    @notes = notes
    @movements = movements
    @steps = movements[position][:steps]
    @leaps = movements[position][:leaps]

    self.opposite_direction_step_filter
    self.penultimate_filter
    self.ultimate_filter
    self.direction_repetition_filter
    self.consecutive_leap_filter
    self.palindrome_filter
    self.note_repetition_filter

    @movements[position][:steps] = @steps
    @movements[position][:leaps] = @leaps
    return @movements
  end

  def self.opposite_direction_step_filter
    #checks whether the previous movement was a large leap
    if @steps[0] && (@notes[@position-1] - @notes[@position]).abs() >= 5
      previous_movement = @notes[@position] - @notes[@position - 1]
      @steps = @steps.select { |move| move.negative? != previous_movement.negative?}
    end
  end

  def self.penultimate_filter
    if (@steps[0] || @leaps[0]) && @position == (@notes.length - 3)
      @steps = @steps.select { |move| (@notes[@position] + move) <= 2 && (@notes[@position] + move) >= -2 }
      @leaps = @leaps.select { |move| (@notes[@position] + move) <= 2 && (@notes[@position] + move) >= 2 }
    end
  end

  def self.ultimate_filter
    if @position == @notes.length - 2
      @leaps = []
      @steps = @steps.select { |move| @notes[@position] + move == 0 }
    end
  end

  def self.direction_repetition_filter
    if @steps[0] || @leaps[0]
      if self.positive_step_repetition_check
        @steps = @steps.select { |move| move.negative? == true}
        @leaps = @leaps.select { |move| move.negative? == true}
      elsif self.negative_step_repetition_check
        @steps = @steps.select { |move| move.negative? == false}
        @leaps = @leaps.select { |move| move.negative? == false}
      end
    end
  end

  #not included in self.filter
  def self.positive_step_repetition_check
    #checks for four positive moves in a row
    @position >= 4 && 
    (@notes[@position - 3] - @notes[@position - 4]).positive? &&
    (@notes[@position - 2] - @notes[@position - 3]).positive? &&
    (@notes[@position - 1] - @notes[@position - 2]).positive? &&
    (@notes[@position] - @notes[@position - 1]).positive?
  end

  #not included in self.filter
  def self.negative_step_repetition_check 
    #checks for five negative steps in a row
    @position >= 5 && 
    (@notes[@position - 4] - @notes[@position - 5]).negative? &&
    (@notes[@position - 3] - @notes[@position - 4]).negative? &&
    (@notes[@position - 2] - @notes[@position - 3]).negative? &&
    (@notes[@position - 1] - @notes[@position - 2]).negative? &&
    (@notes[@position] - @notes[@position - 1]).negative?
  end

  def self.consecutive_leap_filter
    if @leaps[0] && @position >= 1 && (@notes[@position] - @notes[@position - 1]).abs() >= 3

      @leaps = @leaps.select { |move| move != -(@notes[@position] - @notes[@position - 1])} #filters out leaps exactly opposite to the previous

      if @position >= 2 && (@notes[@position - 1] - @notes[@position - 2]).abs() >= 3 #filters out three leaps in a row

        @leaps = []

      elsif (@notes[@position] - @notes[@position - 1]).abs() >= 5
        #filters out equal or larger leaps in the same direction as a previous leaps
        @leaps = @leaps.select { |move| move.negative? != (@notes[@position] - @notes[@position - 1]).negative? || move.abs() < (@notes[@position] - @notes[@position - 1]).abs() }
      end
    end
  end

  def self.palindrome_filter
    if (@steps[0] || @leaps[0]) && @position >= 3 && @notes[@position] == @notes[@position - 2]
      if (@notes[@position] - @notes[@position - 3]).abs() <= 2
        @steps = @steps.select { |move| (@notes[@position] + move) != @notes[@position - 3] }
      else
        @leaps = @leaps.select { |move| (@notes[@position] + move) != @notes[@position - 3] }
      end
    end
  end

  def self.note_repetition_filter
    if (@steps[0] || @leaps[0]) && ((@position + 1) / @notes.length.to_f) > 0.25#ignores if there aren't enough notes yet or there are no available moves anyway

      note_count = {}

      if (@position + 1) == @notes.length
        i = @position - 1
      else
        i = @position
      end

      while i >= -1 #counts all notes generated thus far as well as the final tonic
        if note_count[@notes[i]]
          note_count[@notes[i]] += 1
        else
          note_count[@notes[i]] = 1
        end
        i -= 1
      end

      note_count.keys.each do |key|
        if (note_count[key].to_f / @notes.length.to_f) > 0.25
          @steps = []
          @leaps = []
          break
        end
      end
    end
  end
    #three leaps may not occur in a row
    #large leap (5th or more) cannot be followed by a leap
end