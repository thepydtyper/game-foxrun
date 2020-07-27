extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {IDLE, WANDER, CHASE}

var knockback = Vector2.ZERO
var state = CHASE
var velocity = Vector2.ZERO

onready var sprite = $AnimatedSprite
onready var stats = $Stats
onready var playerdetectionzone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController

export var WANDER_RANGE = 4
export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200

func _ready():
	state = pick_random_state([IDLE, WANDER])


func _physics_process(delta):
	
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)
			seek_player()
			
			if wanderController.get_time_left() == 0:
				update_wander()
		WANDER:
			
			seek_player()
			if wanderController.get_time_left() == 0:
				update_wander()
			
			accelerate_towards_point(wanderController.target_position, delta)

			if global_position.distance_to(wanderController.target_position) <= WANDER_RANGE:
				update_wander()
		CHASE:
			var player = playerdetectionzone.player
			if player != null:
				accelerate_towards_point(player.global_position, delta)
			else:
				state = IDLE
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)


func update_wander():
	
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1, 3))


func accelerate_towards_point(point, delta):
	
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0 # so they face the right way when moving


func seek_player():	
	
	if playerdetectionzone.can_see_player():
		state = CHASE


func pick_random_state(state_list):
	
	state_list.shuffle()
	return state_list.pop_front()


func _on_Hurtbox_area_entered(area):
	
	stats.health -= area.damage # calls set_health under the hood
	knockback = area.knockback_vector * 125
	hurtbox.create_hit_effect()


func _on_Stats_no_health():
	queue_free()
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
