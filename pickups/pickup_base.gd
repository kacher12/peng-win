extends Node2D

func _ready() -> void: #zaczelo sie
	pass
	
func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		
		FX.pengu_squash_and_stretch(body)
		# skonczylo sie
		queue_free()
