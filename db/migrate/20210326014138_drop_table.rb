class DropTable < ActiveRecord::Migration[6.1]
  def change
    drop_table :cantus_firmus_generators
  end
end
