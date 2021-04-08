class CantusFirmusScore < ApplicationRecord
  attr_accessor :original_valid_movements, :notes, :length, :current_available_movements, :current_note_position, :iterations

  def startup
    @length = 8
    @notes = []
    @length.times do
      @notes << 0
    end
    @iterations = 1

    @current_note_position = 0
    @current_available_movements = []
    @mode = "ionian"
    @possible = true
  end

  def determine_original_valid_movements
    if @mode == "ionian"
      @original_valid_movements = {
        -12=>{:steps=>[2], :leaps=>[4, 5, 7, 12]}, 
        -10=>{:steps=>[-2, 2], :leaps=>[3, 5, 7, 12]}, 
        -8=>{:steps=>[-2, 1], :leaps=>[-4, 3, 5, 7, 8, 12]}, 
        -7=>{:steps=>[-1, 2], :leaps=>[-5, -3, 4, 7, 12]}, 
        -5=>{:steps=>[-2, 2], :leaps=>[-7, -5, -3, 4, 5, 7, 12]}, 
        -3=>{:steps=>[-2, 2], :leaps=>[-7, -5, -4, 3, 5, 7, 8, 12]}, 
        -1=>{:steps=>[1], :leaps=>[]}, 
        0=>{:steps=>[-1, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7, 12]}, 
        2=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 3, 5, 7, 12]}, 
        4=>{:steps=>[-2, 1], :leaps=>[-12, -7, -5, -4, 3, 5, 7, 8, 12]}, 
        5=>{:steps=>[-1, 2], :leaps=>[-12, -5, -3, 4, 7]}, 
        7=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3, 4, 5, 7]}, 
        9=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -4, 3, 5, 7]}, 
        11=>{:steps=>[1], :leaps=>[]}, 
        12=>{:steps=>[-1, 2], :leaps=>[-12, -7, -5, -3, 4]}, 
        14=>{:steps=>[-2, 2], :leaps=>[-12, -7, -5, -3]}, 
        16=>{:steps=>[-2], :leaps=>[-12, -7, -5, -4]}
      }
    end
  end

  def determine_current_available_movements
    @current_available_movements[@current_note_position] = @original_valid_movements[@notes[@current_note_position]].dup
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
  
  def build_cantus_firmus
    determine_original_valid_movements
    determine_current_available_movements
    while CantusFirmusValidator.valid?(@notes) == false && @possible == true
      iterate
      @current_note_position -= 1
    end

    if @possible == true
      p @notes
      p "#{@iterations} iterations"
      return @notes
      #CantusFirmusValidatorWithPrintStatements.valid?(@notes)
    else
      return "failed"
    end
  end

  def build_a_lot(length, tmt)
    this_many_times = tmt
    this_many_times.times do
      @length = (length)
      @notes = []
      @length.times do
        @notes << 0
      end
      @iterations = 1

      @current_note_position = 0
      @current_available_movements = []

      build_cantus_firmus
    end
  end
end
