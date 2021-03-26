class CreateCantusFirmusGenerators < ActiveRecord::Migration[6.1]
  def change
    create_table :cantus_firmus_generators do |t|

      t.timestamps
    end
  end
end
