extends Node
# JAK NARAZIE TARGETTUJEMY PROGRESSBAR, ALE ZMIENIMY TO NA TEXTUREPROGRESS BAR JAK BEDA GRAFIKII
# Zmieniamy typ argumentu na Node2D
func squash_and_stretch(target: ProgressBar) -> void:
	# Zabezpieczenie przed błędem, gdy obiekt zniknie w trakcie animacji. dzieki gemini!
	if not is_instance_valid(target) or not target.is_inside_tree():
		return
		
	# Zapisujemy oryginalną skalę obiektu (to teraz Vector2)
	var original_scale = target.scale
	
	var tween = target.create_tween()
	
	#SQUUUASH
	# Tworzymy Vector2 tylko z osiami X i Y
	var squash_scale = Vector2(original_scale.x * 1.4, original_scale.y * 0.6)
	tween.tween_property(target, "scale", squash_scale, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# STREEEEEEEEEEEETCH
	
	tween.tween_property(target, "scale", original_scale, 0.5).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

func pengu_squash_and_stretch(target: CharacterBody2D) -> void:
	# Zabezpieczenie przed błędem, gdy obiekt zniknie w trakcie animacji. dzieki gemini!
	if not is_instance_valid(target) or not target.is_inside_tree():
		return
		
	# Zapisujemy oryginalną skalę obiektu (to teraz Vector2)
	var original_scale = target.scale
	
	var tween = target.create_tween()
	
	#SQUUUASH
	# Tworzymy Vector2 tylko z osiami X i Y
	var squash_scale = Vector2(original_scale.x * 1.15, original_scale.y * 0.85)
	tween.tween_property(target, "scale", squash_scale, 0.05).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	# STREEEEEEEEEEEETCH
	
	tween.tween_property(target, "scale", original_scale, 0.3).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
