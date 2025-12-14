extends Node3D

@onready var player: CharacterBody3D = $Player
@onready var experience_particules: Node3D = $ExperienceParticules
@onready var random_map: Node3D = $RandomMap
@onready var section_position_marker_3d: Marker3D = $RandomMap/SectionPositionMarker3D
@onready var generate_more_sections_area_3d: Area3D = $RandomMap/GenerateMoreSectionsArea3D

const EXPERIENCE_BUBBLE = preload("uid://s46ftkewddgi")
var map_sections_folder: String = "res://scenes/map_sections/"
var map_sections: Array = []

var max_sections_amount: int = 15
var map_sections_pool: Array[Node3D] = []
var section_idx: int = 1
var section_scale_x: float = 0

var sections_to_generate_at_start: int = 5

func _ready() -> void:
	map_sections = DirAccess.get_files_at(map_sections_folder)
	
	for loop: int in range(sections_to_generate_at_start):
		_add_map_section()
	
	for loop_bis: int in range(int(sections_to_generate_at_start / 2)):
		var section: Node3D = map_sections_pool.get(0)
		generate_more_sections_area_3d.position.x += section.scale.x

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

# Quand un ennemi meurt, il émet son signal dédié connecté à cette fonction. Qui est donc appelée.
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

# Ajoute un morceau de la carte, dans le cadre de la génération aléatoire de celle-ci
func _add_map_section() -> void:
	# Le chemin du morceau de la carte à charger
	var section_path: String = map_sections_folder + map_sections.pick_random()
	# Le morceau chargé
	var section_packed_scene: PackedScene = load(section_path)
	# Le morceau instancié qui a été chargé
	var section_added: Node3D = section_packed_scene.instantiate()
	
	# Si on veut ajouter une section dans la section pool, mais qu'elle est pleine:
	if map_sections_pool.size() + 1 > max_sections_amount:
		# Suppression du premier morceeau listé dans la section pool
		_remove_map_section()
	# Ajoute la section dans la section pool
	map_sections_pool.append(section_added)
	
	# Ajoute en enfant de la section instanciée dans la scène main.tscn
	random_map.add_child(section_added)
	# Re-nommage de la section
	section_added.name = "SECTION_" + str(section_idx)
	section_idx += 1
	# Re-positionnage de la section par rapport à celle du section_position_marker_3d
	section_added.position.x = section_position_marker_3d.position.x * 2
	section_scale_x = 40.0
	section_position_marker_3d.position.x += section_scale_x / 2

# Supprime une section de la map de la section pool
func _remove_map_section(where_idx: int = 0) -> void:
	# La section instanciée à supprimer
	var section_to_destroy: Node3D = map_sections_pool.get(where_idx)
	# Section supprimée de la section pool
	map_sections_pool.remove_at(where_idx)
	# Objet de la section instanciée détruite
	section_to_destroy.queue_free()

func _on_generate_more_sections_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		_add_map_section()
		generate_more_sections_area_3d.position.x += section_scale_x / 2
