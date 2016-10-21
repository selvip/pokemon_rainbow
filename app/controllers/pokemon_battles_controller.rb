class PokemonBattlesController < ApplicationController
	def index
		@pokemon_battles = PokemonBattle.all
	end

	def new
		@pokemon_battle = PokemonBattle.new
		@list_pokemons = []
		Pokemon.all.each { |poke| @list_pokemons << [poke.name, poke.id] if poke.current_health_point > 0 }
	end

	def create
		@pokemon_battle = PokemonBattle.new(pokemon_battle_params)
		get_each_pokemon
		set_pokemon_battle_attr
		if @pokemon_battle.valid?
			@pokemon_battle.save
			redirect_to @pokemon_battle
		else
			@list_pokemons = Pokemon.all.map { |poke| [poke.name, poke.id] }
			render 'new'
		end
	end

	def destroy
		@pokemon_battle = PokemonBattle.find(params[:id])
		@pokemon_battle.destroy
		redirect_to pokemon_battles_path
	end

	def show
		flash[:danger] = ""
		@pokemon_battle = PokemonBattle.find(params[:id])
		get_each_pokemon
	end

	def attack
		@pokemon_battle = PokemonBattle.find(params[:pokemon_battle_id])
		get_each_pokemon
		if @pokemon_battle.state == "Finished"
			flash[:danger] = "Finished already."
		else
			@attacker = Pokemon.find(params[:attacker_id])
			@pokemon_skill = PokemonSkill.find(params[:skill_id])
			if @attacker.pokemon_skills.include? @pokemon_skill
				if @pokemon_battle.current_turn.odd?
					if @attacker == @pokemon1
						@defender = @pokemon2
						if 	@pokemon_skill.current_pp > 0
							try_to_attack
						else
							flash[:danger] = "Current PP is zero."
						end
					else
						flash[:danger] = "Pokemon 1 turn."
					end
				else
					if @attacker == @pokemon2
						
						@defender = @pokemon1
						if 	@pokemon_skill.current_pp > 0

							try_to_attack
						else
							flash[:danger] = "Current PP is zero."
						end
					else
						flash[:danger] = "Pokemon 2 turn."
					end
				end
			else
				flash[:danger] = "Unauthorized skill."
			end
		end
		render 'show'
	end

	def surrender
		@pokemon_battle = PokemonBattle.find(params[:pokemon_battle_id])
		get_each_pokemon
		surrender = Pokemon.find(params[:surrender_id])
		if @pokemon_battle.current_turn.odd?
			if surrender.id == @pokemon2.id or @pokemon_battle.state == "Finished"
				flash[:danger] = "Cannot surrender on this turn."
			else
				@defender = @pokemon1
				@attacker = @pokemon2
				finishing_game
			end
		else
			if surrender.id == @pokemon1.id or @pokemon_battle.state == "Finished"
				flash[:danger] = "Cannot surrender on this turn."
			else
				@defender = @pokemon2
				@attacker = @pokemon1
				finishing_game
			end
		end
		render 'show'
	end

	private

	def try_to_attack
		@pokemon_skill.current_pp -= 1
		@pokemon_skill.save
		
		@pokemon_battle.current_turn += 1
		@pokemon_battle.save
		
		damage = PokemonBattleCalculator.calculate_damage(
			attacker_pokemon: @attacker, 
			defender_pokemon: @defender, 
			skill_id: @pokemon_skill.skill_id)

		@defender.current_health_point -= damage
		@defender.save
		flash[:danger] = ""
		check_win
	end

	def check_win
		if @defender.current_health_point <= 0
			@defender.current_health_point = 0
			@defender.save
			finishing_game
		end
	end
	
	def finishing_game
		@pokemon_battle.state = "Finished"
		@pokemon_battle.pokemon_winner_id = @attacker.id
		@pokemon_battle.pokemon_loser_id = @defender.id
		@pokemon_battle.experience_gain = PokemonBattleCalculator.calculate_experience(@defender.level)
		@pokemon_battle.save

		@attacker.current_experience += @pokemon_battle.experience_gain
		while PokemonBattleCalculator.level_up?(winner_level: @attacker.level, total_exp: @attacker.current_experience)
			@attacker.level += 1
			increase_status
		end
		@attacker.save

		flash[:danger] = ""
	end

	def pokemon_battle_params
		params.require(:pokemon_battle).permit(
									 :pokemon1_id, 
									 :pokemon2_id
									 )
	end

	def set_pokemon_battle_attr
		@pokemon_battle.current_turn = 1
		@pokemon_battle.state = "Ongoing"
		@pokemon_battle.pokemon1_max_health_point = @pokemon1.max_health_point
		@pokemon_battle.pokemon2_max_health_point = @pokemon2.max_health_point
	end
	def get_each_pokemon
		@pokemon1 = Pokemon.find(@pokemon_battle.pokemon1_id)
		@pokemon2 = Pokemon.find(@pokemon_battle.pokemon2_id)
	end

end