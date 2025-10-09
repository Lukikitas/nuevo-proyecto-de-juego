extends Node2D

@export var enemy_scene: PackedScene
@export var spawn_radius: float = 600.0
@export var experience_orb_scene: PackedScene   # se inyecta al enemigo

var timer: float = 0.0
var interval: float = 1.5
var difficulty: int = 0

@onready var player := $Player

func _process(delta: float) -> void:
	timer += delta
	if timer >= interval:
		timer = 0.0
		_spawn_enemy()
		difficulty += 1
		interval = max(0.4, 1.5 - difficulty * 0.02)

func _spawn_enemy() -> void:
	if not is_instance_valid(player) or not enemy_scene:
		return
	var e := enemy_scene.instantiate()
	if e.has_variable("experience_orb_scene"):
		e.experience_orb_scene = experience_orb_scene
	var ang := randf() * TAU
	e.global_position = player.global_position + Vector2(spawn_radius, 0).rotated(ang)
	add_child(e)
