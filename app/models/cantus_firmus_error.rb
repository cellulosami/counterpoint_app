class CantusFirmusError < ApplicationRecord
  attr_accessor :notes, :errors, :suggestions

  def evaluate(input)
    @notes = input
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
