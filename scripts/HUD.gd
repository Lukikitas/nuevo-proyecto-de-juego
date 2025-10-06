extends CanvasLayer

@onready var health_bar: ProgressBar = %HealthBar
@onready var experience_bar: ProgressBar = %ExperienceBar

func _ready() -> void:
	# Initialize the bars with default values.
	# We expect the player to send an initial signal with their max values.
	health_bar.max_value = 100
	health_bar.value = 100
	experience_bar.max_value = 100 # Initial goal for level up
	experience_bar.value = 0

func update_health(current_health: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current_health

func update_experience(current_experience: int, max_experience: int) -> void:
	experience_bar.max_value = max_experience
	experience_bar.value = current_experience
