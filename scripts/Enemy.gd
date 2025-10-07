extends CharacterBody2D

@export var speed: float = 90.0
@export var touch_damage: int = 10
@export var max_hp: int = 20
@export var experience_orb_scene: PackedScene  # orbe que deja al morir

var hp: int
var player: Node2D

func _ready() -> void:
	add_to_group("enemy")
	hp = max_hp
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if player and is_instance_valid(player):
		var dir := (player.global_position - global_position).normalized()
		velocity = dir * speed
		move_and_slide()

		# daño por contacto (si chocás usando move_and_slide)
		for i in range(get_slide_collision_count()):
			var col := get_slide_collision(i)
			var other := col.get_collider()
			if other and other.is_in_group("player") and other.has_method("take_damage"):
				other.take_damage(touch_damage)

func take_damage(dmg: int) -> void:
	hp -= dmg
	if hp <= 0:
		_drop_xp()
		queue_free()

func _drop_xp() -> void:
	if experience_orb_scene:
		var orb := experience_orb_scene.instantiate()
		orb.global_position = global_position
		get_tree().current_scene.add_child(orb)
