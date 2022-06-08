extends Control


onready var ip_servidor = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/ip_servidor
onready var nom_player = $MarginContainer/VBoxContainer/nom_player

var player_modelo = preload("res://UI_network/player_modelo.tscn")


func _ready():
	yield(get_tree().create_timer(1),"timeout")
	print(Network.mi_ip)
	$MarginContainer/VBoxContainer/mi_ip.text = "mi ip :  " + str(Network.mi_ip)


func aniadir_player(id, nombre, vida):
	var player_ins = player_modelo.instance()
	player_ins.set_datos(nombre, vida)
	$MarginContainer/VBoxContainer/Container_players.add_child(player_ins)
	
	player_ins.name = str(id) + "_modelo"
	
	player_ins.add_to_group("modelos")


func _on_btn_crear_servidor_pressed():
	Network.crear_servidor()
	
	Network.instanciar_mi_player(Network.mi_id, nom_player.text, 100)


func _on_btn_crear_cliente_pressed():
	if ip_servidor.text != "":
		Network.servidor_ip = ip_servidor.text
		Network.crear_cliente()
		
		Network.instanciar_mi_player(Network.mi_id, nom_player.text, 100)
		
		$MarginContainer/VBoxContainer/Btn_empezar.disabled = true
	else:
		print("INGRESE LA DIRECCION DEL SERVIDOR")


func _on_btn_desconectar_del_servidor_pressed():
	get_tree().network_peer = null
	
	reiniciar_ui_network()


func reiniciar_ui_network():
	var modelos = get_tree().get_nodes_in_group("modelos")
	for i in modelos:
		i.queue_free()
	get_tree().reload_current_scene()
	
	InfoPlayers.players_info.clear()
	InfoPlayers.mi_info.clear()
	
	var players = Mundo.get_node("Players").get_children()
	for p in players:
		p.queue_free()


func _process(delta):
#	print($MarginContainer/VBoxContainer/Container_players.get_children())
	pass


func eliminar_player(id):
	$MarginContainer/VBoxContainer/Container_players.get_node(str(id) + "_modelo").queue_free()


func _on_Btn_empezar_pressed():
	Network.rpc("pre_configurar_juego")
	self.visible = false

