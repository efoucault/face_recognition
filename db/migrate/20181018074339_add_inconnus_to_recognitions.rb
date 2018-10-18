class AddInconnusToRecognitions < ActiveRecord::Migration[5.2]
  def change
    add_column :recognitions, :inconnus, :integer
  end
end
