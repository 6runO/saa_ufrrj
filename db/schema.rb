# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_07_11_010517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "curriculos", force: :cascade do |t|
    t.integer "codigo"
    t.string "periodo"
    t.string "curso"
    t.integer "exigido"
    t.string "turno"
    t.integer "duracao_esperada"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "cursados", force: :cascade do |t|
    t.string "matricula"
    t.string "periodo"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "periodos", force: :cascade do |t|
    t.bigint "curriculo_id", null: false
    t.string "ano_per"
    t.string "inicio_curso"
    t.integer "hrs_aproveitado_regulares"
    t.integer "hrs_aproveitado_atividades"
    t.integer "hrs_apr_regulares"
    t.integer "hrs_apr_eletivas"
    t.integer "hrs_apr_atividades"
    t.integer "hrs_rep_media_regulares_eletivas"
    t.integer "hrs_rep_media_atividades"
    t.integer "hrs_rep_falta_regulares_eletivas"
    t.integer "hrs_rep_falta_atividades"
    t.integer "num_rep_falta_regulares_eletivas"
    t.integer "num_trancado"
    t.integer "num_cancelado"
    t.float "ratio_apr"
    t.float "cr"
    t.float "ira"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["curriculo_id"], name: "index_periodos_on_curriculo_id"
  end

  add_foreign_key "periodos", "curriculos"
end
