class CreateCantusFirmusErrors < ActiveRecord::Migration[6.1]
  def change
    create_table :cantus_firmus_errors do |t|

      t.timestamps
    end
  end
end
