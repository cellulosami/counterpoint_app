class CreateCantusFirmusScores < ActiveRecord::Migration[6.1]
  def change
    create_table :cantus_firmus_scores do |t|

      t.timestamps
    end
  end
end
