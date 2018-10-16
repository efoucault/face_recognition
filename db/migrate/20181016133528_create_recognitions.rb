class CreateRecognitions < ActiveRecord::Migration[5.2]
  def change
    create_table :recognitions do |t|
      t.string :photo

      t.timestamps
    end
  end
end
