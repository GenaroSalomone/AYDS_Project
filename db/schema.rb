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

ActiveRecord::Schema[7.0].define(version: 2023_06_02_143510) do
  create_table "answers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "question_id"
    t.boolean "selected", default: false
    t.string "text"
    t.boolean "correct"
    t.string "question_type"
    t.text "answers_autocomplete", default: ""
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "autocompletes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty_id"
    t.index ["difficulty_id"], name: "index_autocompletes_on_difficulty_id"
  end

  create_table "choices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty_id"
    t.index ["difficulty_id"], name: "index_choices_on_difficulty_id"
  end

  create_table "difficulties", force: :cascade do |t|
    t.string "level"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "question_answers", force: :cascade do |t|
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "trivia_id"
    t.index ["answer_id"], name: "index_question_answers_on_answer_id"
    t.index ["question_id"], name: "index_question_answers_on_question_id"
    t.index ["trivia_id"], name: "index_question_answers_on_trivia_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "type"
    t.integer "difficulty_id"
    t.index ["difficulty_id"], name: "index_questions_on_difficulty_id"
  end

  create_table "trivias", force: :cascade do |t|
    t.integer "user_id"
    t.integer "difficulty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["difficulty_id"], name: "index_trivias_on_difficulty_id"
    t.index ["user_id"], name: "index_trivias_on_user_id"
  end

  create_table "true_falses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "difficulty_id"
    t.index ["difficulty_id"], name: "index_true_falses_on_difficulty_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password"
    t.string "email"
    t.string "password_digest"
  end

  add_foreign_key "answers", "questions"
  add_foreign_key "choices", "difficulties"
  add_foreign_key "question_answers", "answers"
  add_foreign_key "question_answers", "questions"
  add_foreign_key "questions", "difficulties"
  add_foreign_key "trivias", "difficulties"
  add_foreign_key "trivias", "users"
  add_foreign_key "true_falses", "difficulties"
end
