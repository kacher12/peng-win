extends Area2D 

func _ready() -> void: #zaczelo sie

	FX.rotate(self)
func _on_body_entered(body: Node) -> void:
	
	if body.is_in_group("player"):
		

		# Wywoływanie autoload'a HeatSignals z folderu Autoloads
		HeatSignals.on_heat_added.emit(150)
		
		FX.pengu_squash_and_stretch(body)
		# skonczylo sie
		queue_free()
