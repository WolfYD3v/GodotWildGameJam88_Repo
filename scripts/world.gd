extends Node3D

@onready var player: CharacterBody3D = $Player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# 1. Obtenir la liste des nœuds appartenant au groupe "enemies"
	var enemies = get_tree().get_nodes_in_group("enemies")

	# 2. Définir la cible une seule fois
	var target_location = player.global_transform.origin

	# 3. Parcourir la liste et vérifier la validité de chaque nœud
	for enemy in enemies:
		# La fonction 'is_instance_valid()' vérifie si le nœud n'est pas nil ET n'est pas marqué pour queue_free()
		if is_instance_valid(enemy):
			# 4. Appeler la fonction uniquement sur les nœuds valides
			enemy.update_target_location(target_location)
		else:
			# Utile pour le debug : savoir quel nœud a été ignoré
			# print("Nœud ennemi invalide ignoré lors de l'appel de groupe.")
			pass
