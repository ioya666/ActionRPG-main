extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")

export var MAX_SPEED = 70
export var ROLL_SPEED = 60
export var ACCELERATION = 400
export var FRICTION = 500

enum {
	MOVE,
	ROLL,
	ATTACK
}

var velocity = Vector2.ZERO
var state = MOVE
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree =$AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var SwordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var hitflashPlayer = $HitflashPlayer

func _ready():
	stats.connect("no_health", self,"queue_free")
	animationTree.active = true
	SwordHitbox.knockback_vector = roll_vector

func _physics_process(delta):
	match state: 
		MOVE: 
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		SwordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if Input.is_action_just_pressed("Roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("Attack"):
		state = ATTACK
	$RollHitbox/CollisionShape2D.set_deferred("disabled", true)
	$Hurtbox/CollisionShape2D.set_deferred("disabled", false)
	move()

func roll_state(_delta):
	velocity = roll_vector * ROLL_SPEED * 1.5
	animationState.travel("Roll")
	$Hurtbox/CollisionShape2D.set_deferred("disabled", true)
	move()

func attack_state(_delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = roll_vector * 0.7
	state = MOVE
func attack_animation_finished():
	state = MOVE

func _on_Hurtbox_area_entered(area):
	if hurtbox.invincible == false:
		stats.health -= area.bat_damage
		hurtbox.start_invincibility(0.5)
		hurtbox.create_hit_effect()
		var playerHurtSound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(playerHurtSound)


func _on_Hurtbox_invincibility_started():
	hitflashPlayer.play("Start")


func _on_Hurtbox_invincibility_ended():
	hitflashPlayer.play("Stop")
