extends CharacterBody2D

signal health_changed(current_health, max_health)
signal experience_changed(current_experience, max_experience)

@export var speed: float = 300.0
@export var bullet_scene: PackedScene
@export var max_health: int = 100
var health: int

var experience: int = 0
var experience_to_next_level: int = 100

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("player")
	health = max_health
	health_changed.emit(health, max_health)
	experience_changed.emit(experience, experience_to_next_level)

func get_input() -> Vector2:
	var input_direction := Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1
	return input_direction.normalized()

func _physics_process(delta: float) -> void:
	var direction := get_input()
	velocity = direction * speed
	move_and_slide()

func find_closest_enemy() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemy")
	var closest_enemy: Node2D = null
	var min_distance_sq: float = INF
	for enemy in enemies:
		var distance_sq := global_position.distance_squared_to(enemy.global_position)
		if distance_sq < min_distance_sq:
			min_distance_sq = distance_sq
			closest_enemy = enemy
	return closest_enemy

func take_damage(amount: int) -> void:
	health -= amount
	health_changed.emit(health, max_health)

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	if health <= 0:
		get_tree().reload_current_scene()

async func _on_shoot_timer_timeout() -> void:
	var target: Node2D = find_closest_enemy()
	if target and bullet_scene:
		var bullet = bullet_scene.instantiate()
		get_tree().root.add_child(bullet)
		# Wait until the bullet's _ready() function has completed.
		await bullet.ready
		# Now it's safe to call the setup function.
		var bullet_direction = (target.global_position - global_position).normalized()
		bullet.setup(global_position, bullet_direction)

func _on_orb_collector_area_entered(area: Area2D) -> void:
	if "experience_amount" in area:
		experience += area.experience_amount
		if experience >= experience_to_next_level:
			experience -= experience_to_next_level
			experience_to_next_level = int(experience_to_next_level * 1.5)

		experience_changed.emit(experience, experience_to_next_level)
		area.queue_free()
