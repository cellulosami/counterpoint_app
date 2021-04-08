class RemoveColumnsFromCantusFirmusScores < ActiveRecord::Migration[6.1]
  def change
    remove_column :cantus_firmus_scores, :length
    remove_column :cantus_firmus_scores, :notes
    remove_column :cantus_firmus_scores, :iterations
  end
end
