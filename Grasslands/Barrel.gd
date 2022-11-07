extends StaticBody2D

const Effect = preload("res://Effects/BarrelEffect.tscn")

func create_effect():
	var effect = Effect.instance()
	get_parent().add_child(effect)
	effect.global_position = global_position

func _on_Hurtbox_area_entered(_area):
	create_effect()
	queue_free()
