extends Area2D

onready var timer = $Timer
onready var collisionShape = $CollisionShape2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var invincibile = false setget set_invincible

signal invincibility_started
signal invincibility_ended

func set_invincible(value):
	invincibile = value
	if invincibile == true:
		emit_signal("invincibility_started")
	else:
		emit_signal("invincibility_ended")


func start_invincibility(duration):
	self.invincibile = true
	timer.start(duration)

func create_hit_effect():
	
	var effect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position


func _on_Timer_timeout():
	self.invincibile = false


func _on_Hurtbox_invincibility_started():
	collisionShape.set_deferred("disabled", true)


func _on_Hurtbox_invincibility_ended():
	collisionShape.disabled = false
