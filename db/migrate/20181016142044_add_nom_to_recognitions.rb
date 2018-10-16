class AddNomToRecognitions < ActiveRecord::Migration[5.2]
  def change
    add_column :recognitions, :nom, :string
  end
end
