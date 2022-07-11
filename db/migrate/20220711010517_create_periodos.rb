class CreatePeriodos < ActiveRecord::Migration[6.1]
  def change
    create_table :periodos do |t|
      t.references :curriculo, null: false, foreign_key: true
      t.string :ano_per
      t.string :inicio_curso
      t.integer :hrs_aproveitado_regulares
      t.integer :hrs_aproveitado_atividades
      t.integer :hrs_apr_regulares
      t.integer :hrs_apr_eletivas
      t.integer :hrs_apr_atividades
      t.integer :hrs_rep_media_regulares_eletivas
      t.integer :hrs_rep_media_atividades
      t.integer :hrs_rep_falta_regulares_eletivas
      t.integer :hrs_rep_falta_atividades
      t.integer :hrs_matriculado_regulares
      t.integer :hrs_matriculado_eletivas
      t.integer :hrs_matriculado_atividades
      t.integer :num_rep_falta_regulares_eletivas
      t.integer :num_trancado
      t.integer :num_cancelado
      t.float :ratio_apr
      t.float :cr
      t.float :ira

      t.timestamps
    end
  end
end
