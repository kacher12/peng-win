extends "res://pickups/pickup_base.gd"

@export var attraction_speed: float = 5.0


func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		
		FX.pengu_squash_and_stretch(body)
		# skonczylo sie
		queue_free()
		
# przyciąga pickupy do pingwina

func attract_object(target: Node2D, delta: float):
	target.global_position = target.global_position.lerp(global_position, attraction_speed * delta)

func lerp_pickups(delta: float): 
	var bodies = 1    # napraw "overlapping bodies" czy cos
	
	for body in bodies:
		if body.is_in_group("magnetable"):
			attract_object(body, delta)


func _physics_process(delta):
	lerp_pickups(delta)
