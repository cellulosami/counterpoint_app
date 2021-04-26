class CantusFirmusError < ApplicationRecord
  attr_accessor :notes, :errors, :suggestions, :mode

  def evaluate(input)
    @notes = translate_notes(input)
    p @mode
    p @translator
    p @translator[:"e/3"]
    p @notes
    @errors = []
    @suggestions = []
    range_check

    if @errors == []
      @errors << "No errors."
    end
    if @suggestions == []
      @suggestions << "No suggestions."
    end
  end

  def translate_notes(notes)
    setup_translator
    return notes.map { |note| @translator[note] }
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
        "c/3" => -2,
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
  
  def range_check
    p "range check"
    if @notes.max - @notes.min > 16
      p "bad range"
      @errors << "Range exceeds a 10th."
    elsif @notes.max - @notes.min > 12
      p "ehh range"
      @suggestions << "Range exceeds an octave."
    else
      p "good range"
    end
  end
end
