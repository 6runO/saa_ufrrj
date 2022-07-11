class CreateCursados < ActiveRecord::Migration[6.1]
  def change
    create_table :cursados do |t|
      t.string :matricula
      t.string :periodo

      t.timestamps
    end
  end
end
