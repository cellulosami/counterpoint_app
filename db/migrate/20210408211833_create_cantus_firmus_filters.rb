class CreateCantusFirmusFilters < ActiveRecord::Migration[6.1]
  def change
    create_table :cantus_firmus_filters do |t|

      t.timestamps
    end
  end
end
