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
    p @mode
    p @translator
    p @notes
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
        "c/4" => 10,
        "d/5" => 12,
        "e/5" => 14,
        "f/5" => 15,
      }
    end
  end
  
  def error_check
    begin_and_end_check
    range_check
    penultimate_check
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

end
