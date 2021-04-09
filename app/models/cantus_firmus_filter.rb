class CantusFirmusFilter < ApplicationRecord
  def self.filter(movements, position, notes)
    @position = position
    @notes = notes
    @movements = movements
    @steps = movements[position][:steps]
    @leaps = movements[position][:leaps]
    
    self.range_filter
    self.pre_climax_filter
    self.duplet_repetition_filter
    self.opposite_direction_step_filter
    self.penultimate_filter
    self.ultimate_filter
    self.direction_repetition_filter
    self.consecutive_leap_filter
    self.palindrome_filter
    self.note_repetition_filter
    self.climax_filter

    @movements[position][:steps] = @steps
    @movements[position][:leaps] = @leaps
    return @movements
  end

  def self.range_filter
    if (@notes[0..@position].max - @notes[0..@position].min) > 12
      @steps = []
      @leaps = []
    end
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

  def self.duplet_repetition_filter
    if @position > 1 && @notes[@position] == @notes[@position - 2]
      if @steps[0]
        @steps = @steps.select { |move| (@notes[@position] + move) != @notes[@position - 1] }
      end
      if @leaps[0]
        @leaps = @leaps.select { |move| (@notes[@position] + move) != @notes[@position - 1] }
      end
    end
  end

  def self.pre_climax_filter
    if ((@position + 1) / @notes.length.to_f) <= 0.25 && (@steps[0] || @leaps[0])
      if @notes[0..@position].max - @notes[0..@position].min >= 12 #checks if the maximum range has been hit too early
        @steps = []
        @leaps = []
      else
        @steps = @steps.select { |move| (@notes[@position] + move) < 11 }
        @leaps = @leaps.select { |move| (@notes[@position] + move) < 11 }
      end
    end
  end

  def self.climax_filter
    if (@position + 1) / @notes.length.to_f >= 0.75 && (@steps[0] || @leaps [0])
      
      current_notes = @notes[0..@position]
      if current_notes.max == 11
        @leaps = []
        @steaps = []
      elsif current_notes.max < 3
        @leaps = []
        @steaps = []
        p "codeuroy"
      else
        highest_note = 2
        good_climax = false
        i = 0
        while i < current_notes.length
          if current_notes[i] > highest_note
            highest_note = current_notes[i]
            if ((i + 1) / @notes.length.to_f) > 0.25 && ((i + 1) / @notes.length.to_f) < 0.75 #checks if climax is toward middle
              good_climax = true
            else
              good_climax = false
            end
          elsif current_notes[i] == highest_note
            good_climax = false
          end 

          i += 1
        end
        if good_climax == false
          @steps = []
          @leaps = []
        else
          @steps = @steps.select { |move| (@notes[@position] + move) < highest_note }
          @leaps = @leaps.select { |move| (@notes[@position] + move) < highest_note }
        end
      end
    end
  end
end