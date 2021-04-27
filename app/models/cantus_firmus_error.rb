class CantusFirmusError < ApplicationRecord
  attr_accessor :notes, :errors, :suggestions, :mode

  def evaluate(input)
    setup_evaluate(input)
    
    if @diatonic == true
      error_check
    end

    if @errors == []
      @errors << "No errors."
    end
    if @suggestions == []
      @suggestions << "No suggestions."
    end
  end

  def setup_evaluate(input)
    @diatonic = true
    @errors = []
    @suggestions = []
    @notes = translate_notes(input)
    @length = @notes.length
    p @mode
    p @translator
    p @notes
    setup_reverse_translator
  end

  def translate_notes(notes) #converts note strings into integers
    setup_translator
    result = []
    notes.each do |note|
      if @translator[note]
        result << @translator[note]
      else
        @errors << "Not all notes are diatonic. Please correct in order to see other errors/suggestions."
        @diatonic = false
      end
    end
    return result
  end

  def setup_translator
    if @mode == "ionian"
      @translator = {
        "e/3" => -8,
        "f/3" => -7,
        "g/3" => -5,
        "a/3" => -3,
        "b/3" => -1,
        "c/4" => 0,
        "d/4" => 2,
        "e/4" => 4,
        "f/4" => 5,
        "g/4" => 7,
        "a/4" => 9,
        "b/4" => 11,
        "c/5" => 12,
        "d/5" => 14,
        "e/5" => 16,
      }
    elsif @mode == "dorian"
      @translator = {
        "f/3" => -9,
        "g/3" => -7,
        "a/3" => -5,
        "b/3" => -3,
        "c/4" => -2,
        "c#/4" => -1,
        "d/4" => 0,
        "e/4" => 2,
        "f/4" => 3,
        "g/4" => 5,
        "a/4" => 7,
        "b/4" => 9,
        "c/5" => 10,
        "d/5" => 12,
        "e/5" => 14,
        "f/5" => 15,
      }
    end
  end

  def setup_reverse_translator
    if @mode == "ionian"
      @reverse_translator = {
        "-8" => "E3",
        "-7" => "F3",
        "-5" => "G3",
        "-3" => "A3",
        "-1" => "B3",
        "0" => "C4",
        "2" => "D4",
        "4" => "E4",
        "5" => "F4",
        "7" => "G4",
        "9" => "A4",
        "11" => "B4",
        "12" => "C5",
        "14" => "D5",
        "16" => "E5"
      }
    elsif @mode == "dorian"
      @reverse_translator = {
        "-9" => "F3",
        "-7" => "G3",
        "-5" => "A3",
        "-3" => "B3",
        "-2" => "C4",
        "0" => "D4",
        "2" => "E4",
        "3" => "F4",
        "5" => "G4",
        "7" => "A4",
        "9" => "B4",
        "10" => "C5",
        "12" => "D5",
        "14" => "E5",
        "15" => "F5"
      }
    end
  end
  
  def error_check
    #if unclear about what any of these do, read their error/suggestion messages
    begin_and_end_check
    range_check
    penultimate_check
    climax_value_check
    climax_position_check
    climax_repetition_check
    note_stagnation_check
    note_repetition_check
    duplet_repetition_check
    triplet_repetition_check
    leap_percentage_check
    leap_abation_check
    leap_repetition_check
    direction_repetition_check
    opposite_direction_step_check
    equal_and_opposite_leap_check
    palindrome_check
    leading_tone_resolution_check
  end

  def begin_and_end_check
    p "begin and end check"
    if @notes[0] != 0
      errors << "First note is not the tonic."
    end

    if @notes[-1] != 0
      errors << "Last note is not the tonic."
    elsif @notes[0] == 0
      p "good begin and end"
    end
  end
  
  def range_check
    p "range check"
    if @notes.max - @notes.min > 16
      @errors << "Range exceeds a 10th."
    elsif @notes.max - @notes.min > 12
      @suggestions << "Range exceeds an octave."
    else
      p "good range"
    end
  end

  def penultimate_check
    p "penultimate check"
    if @notes[-2] < @notes[-1] - 2 || @notes[-2] == @notes[-1] || @notes[-2] > @notes[-1] + 2
      @errors << "Final note is not approached by step."
    else
      p "good penultimate"
    end
  end

  def climax_value_check
    p "climax value check"
    if @notes.max < 3
      errors << "Climax should be at least a third above the starting note."
    elsif @notes.max == 10 || @notes.max == 11
      errors << "Climax should not be the leading tone (7th)."
    else
      p "good climax value"
    end
  end

  def climax_position_check
    p "climax position check"
    max_position = (@notes.index(@notes.max) + 1) / @length.to_f
    if max_position <= 0.15
      @errors << "Climax should be later in the melody."
    elsif max_position <= 0.25
      @suggestions << "Climax might work better later in the melody."
    elsif max_position >= 0.85
      @errors << "Climax should be earlier in the melody."
    elsif max_position >= 0.75
      @suggestions << "Climax might work better earlier in the melody."
    else
      p "good climax position"
    end
  end

  def climax_repetition_check
    "climax repetition check"
    if @notes.count(@notes.max) > 1
      @errors << "Climax should not occur more than once."
    else
      "good climax"
    end
  end

  def note_stagnation_check
    p "note stagnation check"
    i = 1
    while i < @notes.length
      if @notes[i] == @notes[i-1]
        @errors << "Note #{i + 1} is the same as its preceeding note; notes should not repeat."
      end
      i += 1
    end
  end

  def note_repetition_check
    p "note repetition check"
    note_counts = {}
    @notes.each do |note|
      if note_counts[note]
        note_counts[note] += 1
      else
        note_counts[note] = 1
      end
    end

    note_counts.each do |count|
      if count[1] / @notes.length.to_f > 0.35
        @errors << "#{@reverse_translator[count[0].to_s]} occurs too often."
      elsif count[1] / @notes.length.to_f > 0.25
        @suggestions << "#{@reverse_translator[count[0].to_s]} might occur too often."
      end
    end
  end

  def duplet_repetition_check
    p "duplet repetition check"
    i = 3
    while i < @notes.length
      if [@notes[i-3], @notes[i-2]] == [@notes[i-1], @notes[i]]
        @errors << "Notes #{i-2}-#{i-1} are a repetition of notes #{i}-#{i+1}."
      end
      i += 1
    end
  end

  def triplet_repetition_check
    p "triplet repetition check"
    i = 5
    while i < @notes.length
      if [@notes[i-5], @notes[i-4], @notes[i-3]] == [@notes[i-2], @notes[i-1], @notes[i]]
        @errors << "Notes #{i-4}-#{i-2} are a repetition of notes #{i-1}-#{i+1}."
      end
      i += 1
    end
  end

  #motif repetition check (repetition of four notes in a row anywhere in the melody)

  def leap_percentage_check
    p "leap percentage check"
    leaps = 0
    i = 1
    while i < (@notes.length)
      if ((@notes[i] - @notes[i - 1]).abs()) >= 3
        leaps += 1
      end
      i += 1
    end

    if leaps / @notes.length.to_f > 0.44
      @errors << "There are too many leaps. Use more stepwise motion."
    elsif leaps / @notes.length.to_f > 0.33
      @suggestions << "Fewer leaps and more stepwise motion may be preferable."
    else
      p "good leap percentage"
    end
  end

  def leap_abation_check
    p "leap abation check"
    #check if a move is a leap
    #check if next move is in same direction
    #check is next move is equal or larger
    i = 2
    while i < @notes.length
      move1 = @notes[i-2] - @notes[i-1]
      move2 = @notes[i-1] - @notes[i]
      if move1.abs > 2 && 
        move2.abs >= move1.abs && 
        move1.negative? == move2.negative?
        @errors << "if consecutive leaps occur in the same direction, the second leap should be smaller"
      end
      i += 1
    end
  end

  def leap_repetition_check
    p "leap repetition check"
    i = 3
    while i < @notes.length
      if (@notes[i-2] - @notes[i-3]).abs() > 2 &&
        (@notes[i-1] - @notes[i-2]).abs() > 2 &&
        (@notes[i] - @notes[i-1]).abs() > 2

        starting_note = i - 2
        while (@notes[i+1] - @notes[i]).abs() > 2
          i += 1
        end
        @errors << "From note #{starting_note} to note #{i + 1}, more than two leaps occur in a row"
      end
      i += 1
    end
  end

  def direction_repetition_check
    p "direction repetition check"
  end

  def drc_positive

  end

  def drc_negative

  end

  def opposite_direction_step_check
    p "opposite direction step check"
  end

  def equal_and_opposite_leap_check
    p "equal and opposite leap check"
  end

  def palindrome_check
    p "palindrome check"
  end

  def leading_tone_resolution_check
    p "leading tone resolution check"
  end
end
