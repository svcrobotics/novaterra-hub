class Projet < ApplicationRecord
  belongs_to :user

  validates :nom, presence: true, format: { with: /\A[a-zA-Z0-9_-]+\z/, message: "ne doit contenir que des lettres, chiffres, tirets ou underscores" }
end
