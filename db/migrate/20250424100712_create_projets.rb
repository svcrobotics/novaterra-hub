class CreateProjets < ActiveRecord::Migration[8.0]
  def change
    create_table :projets do |t|
      t.string :nom
      t.string :chemin
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
