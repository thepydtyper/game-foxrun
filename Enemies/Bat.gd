extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {IDLE, WANDER, CHASE}

var knockback = Vector2.ZERO
var state = CHASE
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerdetectionzone = $PlayerDetectionZone

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

func _ready():
	
	print(stats.max_health)
	print(stats.health)


func _physics_process(delta):
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
		WANDER:
			pass
		CHASE:
			var player = playerdetectionzone.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
				sprite.flip_h = velocity.x < 0
			else:
				state = IDLE
	velocity = move_and_slide(velocity)


func seek_player():
	
	if playerdetectionzone.can_see_player():
		state = CHASE


func _on_Hurtbox_area_entered(area):
	
	stats.health -= area.damage # calls set_health under the hood
	knockback = area.knockback_vector * 125


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
