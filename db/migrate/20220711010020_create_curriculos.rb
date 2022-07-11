class CreateCurriculos < ActiveRecord::Migration[6.1]
  def change
    create_table :curriculos do |t|
      t.string :codigo
      t.string :curso
      t.integer :exigido
      t.string :turno

      t.timestamps
    end
  end
end
