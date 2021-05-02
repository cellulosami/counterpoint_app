class CantusFirmusScore < ApplicationRecord
  attr_accessor :original_valid_movements, :notes, :length, :current_available_movements, :current_note_position, :iterations, :mode

  def startup
    @notes = []
    @length.times do
      @notes << 0
    end
    @iterations = 1

    @current_note_position = 0
    @current_available_movements = []
    @possible = true
  end

  def determine_original_valid_movements
    if @mode == "ionian"
      @original_valid_movements = { 
        -8=>{:steps=>[1], :leaps=>[3, 5, 7, 8, 12]}, 
        -7=>{:steps=>[-1, 2], :leaps=>[4, 7, 12]}, 
        -5=>{:steps=>[-2, 2], :leaps=>[-3, 4, 5, 7, 12]}, 
        -3=>{:steps=>[-2, 2], :leaps=>[-5, -4, 3, 5, 7, 8, 12]}, 
        -1=>{:steps=>[1], :leaps=>[]}, 
        0=>{:steps=>[-1, 2], :leaps=>[-7, -5, -3, 4, 5, 7, 12]}, 
        2=>{:steps=>[-2, 2], :leaps=>[-7, -5, -3, 3, 5, 7, 12]}, 
        4=>{:steps=>[-2, 1], :leaps=>[-12, -7, -5, -4, 3, 5, 7, 8, 12]}, 
        5=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 7]}, 
        7=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7]}, 
        9=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -4, 3, 5, 7]}, 
        11=>{:steps=>[1], :leaps=>[]}, 
        12=>{:steps=>[-1, 2], :leaps=>[-12, -7, -5, -3, 4]}, 
        14=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3]}, 
        16=>{:steps=>[-2], :leaps=>[-12, -7, -5, -4]}
      } 
    elsif @mode == "dorian"
      @original_valid_movements = {
        -9=>{:steps=>[2], :leaps=>[4, 7, 12]}, 
        -7=>{:steps=>[-2, 2], :leaps=>[4, 5, 7, 12]}, 
        -5=>{:steps=>[-2, 2], :leaps=>[-4, 3, 5, 7, 12]}, 
        -3=>{:steps=>[-2, 1], :leaps=>[-4, 3, 5, 8, 12]}, 
        -2=>{:steps=>[2], :leaps=>[]}, 
        0=>{:steps=>[-2, 2], :leaps=>[-7, -5, -3, 3, 5, 7, 12]}, 
        2=>{:steps=>[-2, 1], :leaps=>[-7, -5, -4, 3, 5, 7, 8, 12]}, 
        3=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 7, 12]}, 
        5=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7]}, 
        7=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -4, 3, 5, 7]}, 
        9=>{:steps=>[-2, 1], :leaps=>[-12, -7, -4, 3, 5]}, 
        10=>{:steps=>[2], :leaps=>[]}, 
        12=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 3]}, 
        14=>{:steps=>[-2, 1], :leaps=>[-12, -7, -5, -4]}, 
        15=>{:steps=>[-1], :leaps=>[-12, -5, -3]}
      }
    elsif @mode == "aeolian"
      @original_valid_movements = {
        -9=>{:steps=>[2], :leaps=>[5, 7, 12]}, 
        -7=>{:steps=>[-2, 2], :leaps=>[3, 5, 7, 12]}, 
        -5=>{:steps=>[-2, 1], :leaps=>[-4, 3, 5, 7, 12]}, 
        -4=>{:steps=>[-1, 2], :leaps=>[-5, -3, 4, 7, 12]}, 
        -2=>{:steps=>[2], :leaps=>[]}, 
        0=>{:steps=>[-2, 2], :leaps=>[-7, -5, -4, 3, 5, 7, 8, 12]}, 
        2=>{:steps=>[-2, 1], :leaps=>[-7, -4, 3, 5, 8, 12]}, 
        3=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 5, 7, 12]}, 
        5=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 3, 5, 7]}, 
        7=>{:steps=>[-2, 1], :leaps=>[-12, -7, -5, -4, 3, 5, 7]}, 
        8=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 7]}, 
        10=>{:steps=>[2], :leaps=>[]}, 
        12=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -4, 3]}, 
        14=>{:steps=>[-2, 1], :leaps=>[-12, -7, -4]}, 
        15=>{:steps=>[-1], :leaps=>[-12, -7, -5, -3]}
      }
    end
  end

  def determine_current_available_movements
    @current_available_movements[@current_note_position] = @original_valid_movements[@notes[@current_note_position]].dup
    p "round ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`"
    p @current_note_position
    p @notes
    p @current_available_movements
  end

  def execute_movement
    # p @notes
    if rand(1..100) <= 33 && @current_available_movements[@current_note_position][:leaps][0]
      leap
    else
      if @current_available_movements[@current_note_position][:steps][0]
        step
      else
        leap
      end
    end

    @notes[@current_note_position+1] = @notes[@current_note_position] + @executed_movement
  end

  def step
    @executed_movement = @current_available_movements[@current_note_position][:steps].sample
    @current_available_movements[@current_note_position][:steps] = @current_available_movements[@current_note_position][:steps] - [@executed_movement]
  end

  def leap
    leap_selected  = false
    while leap_selected == false
      leap_offered = @current_available_movements[@current_note_position][:leaps].sample
      if leap_offered.abs() < rand(1..17) # this condition lowers the probability of larger leaps being chosen
        leap_selected = true
      end
    end
    @executed_movement = leap_offered
    @current_available_movements[@current_note_position][:leaps] = @current_available_movements[@current_note_position][:leaps] - [@executed_movement]
  end

  def available_movement_check
    if @current_available_movements[@current_note_position][:steps][0] || @current_available_movements[@current_note_position][:leaps][0]
      return true
    else
      return false
    end
  end

  def iterate
    while @current_note_position < ( @length - 1 )
      if available_movement_check == true
        execute_movement
        @current_note_position += 1
        determine_current_available_movements
        @current_available_movements = CantusFirmusFilter.filter(@current_available_movements, @current_note_position, @notes)
      else
        @current_note_position -= 1
        @iterations += 1
        if @current_note_position < 0
          p "no possible note combination"
          @possible = false
          break
        end
      end
    end
  end
  
  def convert_to_notation
    if @mode == "ionian"
      converter = {
        "-12" => "c/3",
        "-10" => "d/3",
        "-8" => "e/3",
        "-7" => "f/3",
        "-5" => "g/3",
        "-3" => "a/3",
        "-1" => "b/3",
        "0" => "c/4",
        "2" => "d/4",
        "4" => "e/4",
        "5" => "f/4",
        "7" => "g/4",
        "9" => "a/4",
        "11" => "b/4",
        "12" => "c/5",
        "14" => "d/5",
        "16" => "e/5"
      }
    elsif @mode == "dorian"
      converter = {
        "-12" => "d/3",
        "-10" => "e/3",
        "-9" => "f/3",
        "-7" => "g/3",
        "-5" => "a/3",
        "-3" => "b/3",
        "-2" => "c/4",
        "0" => "d/4",
        "2" => "e/4",
        "3" => "f/4",
        "5" => "g/4",
        "7" => "a/4",
        "9" => "b/4",
        "10" => "c/5",
        "12" => "d/5",
        "14" => "e/5",
        "15" => "f/5"
      }
    elsif @mode == "aeolian"
      converter = {
        "-12" => "a/3",
        "-10" => "b/3",
        "-9" => "c/4",
        "-7" => "d/4",
        "-5" => "e/4",
        "-4" => "f/4",
        "-2" => "g/4",
        "0" => "a/4",
        "2" => "b/4",
        "3" => "c/5",
        "5" => "d/5",
        "7" => "e/5",
        "8" => "f/5",
        "10" => "g/5",
        "12" => "a/5",
        "14" => "b/5",
        "15" => "c/5"
      }
    end
    @notes = @notes.map { |note| converter[note.to_s]}
    if @mode == "dorian" && @notes[-2] == "c/4"
      @notes[-2] = "c#/4"
    end
    if @mode == "aeolian"
      if @notes[-3] == "f/4"
        @notes[-3] = "f#/4"
      end
      if @notes[-2] == "g/4"
        @notes[-2] = "g#/4"
      end
    end
    return @notes
  end

  def build_cantus_firmus
    determine_original_valid_movements
    determine_current_available_movements
    while CantusFirmusValidator.valid?(@notes) == false && @possible == true
      iterate
      @current_note_position -= 1
      if @iterations % 1000 == 0
        p @iterations
        p @notes
      end
    end

    if @possible == true
      p @notes
      p "#{@iterations} iterations"
      return convert_to_notation
      #CantusFirmusValidatorWithPrintStatements.valid?(@notes)
    else
      return "failed"
    end
  end
end
