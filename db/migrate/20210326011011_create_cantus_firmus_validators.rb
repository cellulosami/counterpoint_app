class CreateCantusFirmusValidators < ActiveRecord::Migration[6.1]
  def change
    create_table :cantus_firmus_validators do |t|

      t.timestamps
    end
  end
end
