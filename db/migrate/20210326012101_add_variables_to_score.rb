class AddVariablesToScore < ActiveRecord::Migration[6.1]
  def change
    add_column :cantus_firmus_scores, :notes, :integer, array: true, default: []
    add_column :cantus_firmus_scores, :iterations, :integer
  end
end
