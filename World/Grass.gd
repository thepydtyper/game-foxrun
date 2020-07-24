extends Node2D

func create_grass_effect():
	
	var GrassEffect = load("Effects/GrassEffect.tscn")
	var grassEffect = GrassEffect.instance()
	var world = get_tree().current_scene
	
	world.add_child(grassEffect)
	#set effect's position to the position of this (grass node)
	grassEffect.global_position = global_position


func _on_Hurtbox_area_entered(area):
	
	create_grass_effect()
	queue_free()
