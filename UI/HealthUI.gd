extends Control

var health = 4 setget set_health
var max_health = 4 setget set_max_health
var stamina = 4 setget set_stamina
var max_stamina = 4 setget set_max_stamina

onready var healthBar = $HealthBar
onready var staminaBar = $StaminaBar

func set_health(value):
	health = clamp(value, 0, max_health)
	if healthBar != null:
		pass
func set_max_health(value):
	max_health = max(value, 1)
	self.health = min(health, max_health)

func set_stamina(value):
	stamina = clamp(value, 0, max_health)
	max_stamina = max(value, 1)
	if staminaBar != null:
		pass

func set_max_stamina(value):
	max_stamina = max(value, 1)
	self.stamina = min(stamina, max_stamina)
func _ready():
	self.max_health = PlayerStats.max_health
	self.health = PlayerStats.health
	self.max_stamina = PlayerStats.max_stamina
	self.stamina = PlayerStats.stamina
# warning-ignore:return_value_discarded
	PlayerStats.connect("health_changed", self, "set_health")
# warning-ignore:return_value_discarded
	PlayerStats.connect("max_health_changed", self, "set_max_health")
