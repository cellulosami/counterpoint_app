class AddDefaultToLengthInCantusFirmusScores < ActiveRecord::Migration[6.1]
  def change
    change_column_default :cantus_firmus_scores, :length, 8
  end
end
