class AddLangueAndNiveauToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :langue, :string
    add_column :users, :niveau, :integer
  end
end
