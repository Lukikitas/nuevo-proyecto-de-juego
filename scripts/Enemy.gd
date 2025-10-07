extends CharacterBody2D

@export var speed: float = 200.0
@export var max_health: int = 100
var health: int
@export var experience_orb_scene: PackedScene

var player_node: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_bar_timer: Timer = %HealthBarTimer

func _ready() -> void:
	add_to_group("enemy")
	health = max_health
	player_node = get_tree().get_first_node_in_group("player")

	# Initialize health bar
	health_bar.max_value = max_health
	health_bar.value = health
	health_bar.visible = false

func _physics_process(delta: float) -> void:
	if player_node:
		var direction := (player_node.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()

		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			if collision:
				var collider = collision.get_collider()
				if collider and collider.is_in_group("player"):
					# Calculate damage as 10% of the player's max health
					if "max_health" in collider:
						var damage_to_deal = int(collider.max_health * 0.1)
						collider.take_damage(damage_to_deal)

func take_damage(amount: int) -> void:
	health -= amount

	# Update and show health bar
	health_bar.value = health
	health_bar.visible = true
	health_bar_timer.start()

	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "modulate", Color(1, 0.2, 0.2, 1), 0.1)

	if health <= 0:
		if experience_orb_scene:
			var orb = experience_orb_scene.instantiate()
			orb.global_position = global_position
			get_tree().root.add_child(orb)
		queue_free()

func _on_health_bar_timer_timeout() -> void:
	health_bar.visible = false
