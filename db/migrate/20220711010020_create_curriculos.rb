class CreateCurriculos < ActiveRecord::Migration[6.1]
  def change
    create_table :curriculos do |t|
      t.integer :codigo
      t.string :periodo
      t.string :curso
      t.integer :exigido
      t.string :turno
      t.integer :duracao_esperada

      t.timestamps
    end
  end
end
