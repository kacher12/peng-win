extends Node

# JAK NARAZIE TARGETTUJEMY PROGRESSBAR, ALE ZMIENIMY TO NA TEXTUREPROGRESS BAR JAK BEDA GRAFIKII
# Zmieniamy typ argumentu na Node2D
func squash_and_stretch(target: TextureProgressBar) -> void:
	if not is_instance_valid(target) or not target.is_inside_tree():
		return
		
	# 1. Jeśli obiekt ma już przypisanego działającego tweena z tej funkcji - ZABIJMY GO
	if target.has_meta("fx_tween"):
		var old_tween = target.get_meta("fx_tween")
		if is_instance_valid(old_tween) and old_tween.is_running():
			old_tween.kill()
			
	# 2. Pobieramy prawdziwą bazową skalę. Jeśli jeszcze jej nie zapisaliśmy, robimy to teraz.
	var original_scale: Vector2
	if target.has_meta("base_scale"):
		original_scale = target.get_meta("base_scale")
	else:
		original_scale = target.scale
		target.set_meta("base_scale", original_scale)
	
	# Zabezpieczenie: Resetujemy skalę do bazowej przed startem nowej animacji
	target.scale = original_scale
	
	var tween = target.create_tween()
	# Zapamietywanie tweena, aby moc go zniszczyc po koncu animacji. Wtedy pasek zawsze bedzie wracal do stanu przed.
	target.set_meta("fx_tween", tween) 
	
	# SQUUUASH
	var squash_scale = Vector2(original_scale.x * 1.4, original_scale.y * 0.6)
	tween.tween_property(target, "scale", squash_scale, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# STREEEEEEEEEEEETCH
	tween.tween_property(target, "scale", original_scale, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func pengu_squash_and_stretch(target: CharacterBody2D) -> void:
	if not is_instance_valid(target) or not target.is_inside_tree():
		return
		
	# Dokładnie ta sama logika co wyżej dla Pingwina
	if target.has_meta("fx_tween"):
		var old_tween = target.get_meta("fx_tween")
		if is_instance_valid(old_tween) and old_tween.is_running():
			old_tween.kill()
			
	var original_scale: Vector2
	if target.has_meta("base_scale"):
		original_scale = target.get_meta("base_scale")
	else:
		original_scale = target.scale
		target.set_meta("base_scale", original_scale)
		
	target.scale = original_scale
	
	var tween = target.create_tween()
	target.set_meta("fx_tween", tween)
	
	# SQUUUASH
	var squash_scale = Vector2(original_scale.x * 1.15, original_scale.y * 0.85)
	tween.tween_property(target, "scale", squash_scale, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# STREEEEEEEEEEEETCH
	tween.tween_property(target, "scale", original_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

static func rotate(node: Area2D, duration_per_turn: float = 2.0) -> Tween:
	if not is_instance_valid(node):
		return null
	var tween = node.create_tween()
	tween.set_loops()
	tween.tween_property(node, "rotation", 2 * PI, duration_per_turn).as_relative()
	return tween
