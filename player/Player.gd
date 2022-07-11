extends Area2D


func mostrar_datos(info : Dictionary):
	$Nombre.text = str(info["nombre"])
	$Vida.text = str(info["vida"])


func _input(event):
	if self.is_network_master():
		if event is InputEventMouseMotion:
				self.global_position = event.position
				rpc_unreliable("actualizar_pos",self.global_position)
		if event is InputEventMouseButton:
			if event.button_index == 1 and event.pressed:
				atacar()
				rpc("atacar")
		
		if event is InputEventScreenDrag:
			self.global_position = event.position


puppet func atacar():
	$Ataque.visible = true
	$Ataque/Area2D.monitorable = true
	$Ataque/Area2D.monitoring = true
	yield(get_tree().create_timer(0.1),"timeout")
	$Ataque.visible = false
	$Ataque/Area2D.monitorable = false
	$Ataque/Area2D.monitoring = false

puppet func recibir_danio(id):
	print("DANNNiiioooo")
	print("MI INFO: ",InfoPlayers.mi_info)
	print("INFO PLAYERS: ",InfoPlayers.players_info)
	
#	InfoPlayers.players_info["vida"] -=  10
	InfoPlayers.players_info[id]["vida"] -=  10
	
	mostrar_datos(InfoPlayers.players_info[id])

func _on_Player_area_entered(area):
	if self.is_network_master():
		if area.is_in_group("ataque"):
			recibir_danio(Network.mi_id)
			rpc("recibir_danio", Network.mi_id)


#master func recibir_danio():
#	rpc("danio_p")
#	danio_m()


#PEER
puppet func actualizar_pos(pos):
	self.global_position = pos

#
#puppet func danio_p():
#	var id = get_tree().get_rpc_sender_id()
#	InfoPlayers.players_info[id]["vida"] = InfoPlayers.players_info[id]["vida"] - 10
#	get_parent().mostrar_mi_info(InfoPlayers.players_info[id]["nombre"], InfoPlayers.players_info[id]["vida"])
#
#func danio_m():
#	var id = get_tree().get_rpc_sender_id()
#	InfoPlayers.mi_info["vida"] = InfoPlayers.mi_info["vida"] - 10
#	get_parent().mostrar_mi_info(InfoPlayers.mi_info["nombre"], InfoPlayers.mi_info["vida"])



