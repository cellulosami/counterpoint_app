class AddLengthToCantusFirmusScore < ActiveRecord::Migration[6.1]
  def change
    add_column :cantus_firmus_scores, :length, :integer
  end
end
