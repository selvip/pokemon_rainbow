class Pokemon < ApplicationRecord
	belongs_to :pokedex
	has_many :pokemon_skills, dependent: :destroy
	has_many :skills, through: :pokemon_skills
	has_many :pokemon
	validates :name, 
		presence: true,
		uniqueness: true
	validates :level, 
		presence: true,
		numericality: {only_integer: true, greater_than: 0}
	validates :max_health_point, 
		presence: true,
		numericality: {only_integer: true, greater_than: 0}
	validates :current_health_point, 
		presence: true, 
		numericality: {only_integer: true,	greater_than_or_equal_to: 0, less_than_or_equal_to: :max_health_point}
	validates :attack, 
		presence: true,
		numericality: {only_integer: true, greater_than: 0}
	validates :defence, 
		presence: true,
		numericality: {only_integer: true,	greater_than: 0}
	validates :speed, 
		presence: true,
		numericality: {only_integer: true,	greater_than: 0}
	validates :current_experience, 
		presence: true,
		numericality: {only_integer: true,	greater_than_or_equal_to: 0}

	def pokedex_image
		pokedex.image_url
	end
end
