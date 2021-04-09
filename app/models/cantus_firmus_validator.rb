class CantusFirmusValidator < ApplicationRecord
  def self.valid?(notes)
    @notes = notes
    return self.penultimate_check && self.range_check && self.climax_check && leap_percentage_check && self.note_repetition_check && self.pair_repetition_check && self.triplet_repetition_check
  end

  def self.penultimate_check
    if @notes[-2] > -3 && @notes[-2] < 3 && @notes[-2] != 0
      return true
    else
      p "penultimate check is false"
      return false
    end
  end

  def self.climax_check
    highest_note = 2 #starting value assures climax is at least a third above starting pitch
    climax_presence = false

    i = 0
    while i < @notes.length
      if @notes[i] > highest_note
        highest_note = @notes[i]
        if ((i + 1) / @notes.length.to_f) > 0.25 && ((i + 1) / @notes.length.to_f) < 0.75 #checks if climax is toward middle
          climax_presence = true
        else
          climax_presence = false
        end
      elsif @notes[i] == highest_note
        climax_presence = false
      end 
      i += 1
    end

    if highest_note == 11     #checks for leading tone
      climax_presence = false
    end

    if climax_presence == false
      p "climax presence is false"
    end
    return climax_presence
  end

  def self.range_check
    if (@notes.max - @notes.min) < 13
      return true
    else
      p "range check is false"
      return false
    end
  end
  
  def self.leap_percentage_check
    leaps = 0
    i = 0
    while i < (@notes.length - 1)
      if ((@notes[i+1] - @notes[i]).abs()) >= 3
        leaps += 1
      end
      i += 1
    end

    if leaps.to_f / @notes.length.to_f <= 0.33
      return true
    else
      p "leap percentage check is false"
      return false
    end
  end

  def self.note_repetition_check
    note_count = {}
    @notes.each do |note|
      if note_count[note]
        note_count[note] += 1
      else
        note_count[note] = 1
      end
    end

    acceptable_repetitions = true
    note_count.keys.each do |key|
      if (note_count[key].to_f / @notes.length.to_f) > 0.25
        acceptable_repetitions = false
        p "note repetition check is false"
        break
      end
    end
    return acceptable_repetitions
  end

  def self.pair_repetition_check
    i = 0
    acceptable_repetitions = true
    while i < (@notes.length - 3)
      if [@notes[i], @notes[i+1]] == [@notes[i+2], @notes[i+3]]
        acceptable_repetitions = false
        p "pair repetition check is false"
        break
      end
      i += 1
    end
    return acceptable_repetitions
  end

  def self.triplet_repetition_check
    i = 0
    acceptable_repetitions = true
    while i < (@notes.length - 5)
      if [@notes[i], @notes[i+1], @notes[i+2]] == [@notes[i+3], @notes[i+4], @notes[i+5]]
        acceptable_repetitions = false
        p "triplet repetition check is false"
        break
      end
      i += 1
    end
    return acceptable_repetitions
  end
end
