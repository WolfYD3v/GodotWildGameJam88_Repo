extends CharacterBody3D
class_name ExperienceBubble

@onready var collected_audio_stream_player_3d: AudioStreamPlayer3D = $CollectedAudioStreamPlayer3D
@onready var spawn_audio_stream_player_3d: AudioStreamPlayer3D = $SpawnAudioStreamPlayer3D
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
var gravity = 50.0
var player: Player = null
var experience_stored: int = 0

func _ready() -> void:
	spawn_audio_stream_player_3d.play()

func _physics_process(delta: float) -> void:
	if player:
		navigation_agent_3d.target_position = player.global_transform.origin
		var current_location = global_transform.origin
		var next_location = navigation_agent_3d.get_next_path_position()
		var new_velocity = (next_location - current_location).normalized() * 2.0
		
		velocity = new_velocity
		velocity.angle_to(player.global_transform.origin)
		velocity.y -= gravity * delta
		move_and_slide()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		collected_audio_stream_player_3d.play()
		player.experience += experience_stored
		queue_free()

func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()
