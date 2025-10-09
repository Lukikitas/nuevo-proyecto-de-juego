extends Node

@export var enemy_scene: PackedScene
@export var experience_orb_scene: PackedScene

# We'll use a PathFollow2D node to find a random spawn location
@onready var spawn_location: PathFollow2D = %SpawnLocation

func _on_timer_timeout() -> void:
	# Get a random location on the path
	spawn_location.progress_ratio = randf()

	# Instance the enemy scene
	var enemy = enemy_scene.instantiate()

	# Set the experience orb scene on the enemy instance so it knows what to spawn
	enemy.experience_orb_scene = experience_orb_scene

	enemy.global_position = spawn_location.position

	# Add the enemy to the scene tree, making sure it's a child of the Main scene
	owner.add_child(enemy)
#hola
