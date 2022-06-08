extends Sprite



func _on_Area2D_area_entered(area):
	if area.has_method("recibir_danio"):
		area.rpc("recibir_danio")
#	print(area.name)
