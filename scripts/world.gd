extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var experience_particules: Node3D = $ExperienceParticules

const EXPERIENCE_BUBBLE = preload("uid://s46ftkewddgi")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# 1. Obtenir la liste des nœuds appartenant au groupe "enemies"
	var enemies = get_tree().get_nodes_in_group("enemies")

	# 2. Définir la cible une seule fois
	var target_location = player.global_transform.origin

	# 3. Parcourir la liste et vérifier la validité de chaque nœud
	for enemy: Enemy in enemies:
		# Si signal "killed" du noeud n'est pas connecté à la fonction "enemy_killed", faire la connection
		if not enemy.is_connected("killed", enemy_killed):
			enemy.killed.connect(enemy_killed)
		
		# La fonction 'is_instance_valid()' vérifie si le nœud n'est pas nil ET n'est pas marqué pour queue_free()
		if is_instance_valid(enemy):
			# 4. Appeler la fonction uniquement sur les nœuds valides
			enemy.update_target_location(target_location)
		else:
			# Utile pour le debug : savoir quel nœud a été ignoré
			# print("Nœud ennemi invalide ignoré lors de l'appel de groupe.")
			pass

func enemy_killed(_enemy: Enemy) -> void:
	var experience_bubbles_amount_to_spawn: int = 10
	var _enemy_experience_dropped: int = _enemy.experience_dropped
	var _enemy_death_position: Vector3 = _enemy.global_transform.origin
	
	for loop: int in range(experience_bubbles_amount_to_spawn):
		var experience_bubble: ExperienceBubble = EXPERIENCE_BUBBLE.instantiate()
		experience_bubble.experience_stored = _enemy_experience_dropped
		experience_bubble.player = player
		experience_particules.add_child(experience_bubble)
		experience_bubble.position = _enemy_death_position
		await get_tree().create_timer(0.05).timeout
