class CreateGraduations < ActiveRecord::Migration[6.1]
  def change
    create_table :graduations do |t|
      t.string :id_forged
      t.string :curso
      t.string :curriculo
      t.integer :exigido
      t.string :turno
      t.string :inicio

      t.timestamps
    end
  end
end
