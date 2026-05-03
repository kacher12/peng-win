extends "res://pickups/pickup_base.gd"

var ddelta = 1.0


func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		
		FX.pengu_squash_and_stretch(body)
		# skonczylo sie
		queue_free()
		
# przyciąga pickupy do pingwina

func attract_obejct(target: Node2D, delta: float):
	target.global_position = target.global_position.lerp(global_position, attraction_speed * ddelta)

func lerp_pickups(): 
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("magnetable"):
			attract_object(body, ddelta)


func _physics_process(delta):
	pass
