extends Node

var mi_ip = ""
var servidor_ip = ""
var mi_id

const SERVER_PORT = 28960
const MAX_PEERS = 5

var player = preload("res://player/player.tscn")

var players_configurados = []


func _ready():
	
	obtener_mi_ip()
	
	get_tree().connect("network_peer_connected", self, "_player_conectado")
	get_tree().connect("network_peer_disconnected", self, "_player_desconectado")
	
	get_tree().connect("connected_to_server", self, "_coneccion_exitosa_al_servidor")
	get_tree().connect("connection_failed", self, "_coneccion_fallida_al_servidor")
	get_tree().connect("server_disconnected", self, "_desconectado_del_servidor")


func obtener_mi_ip():
	if OS.get_name() == "Windows":
		mi_ip = IP.get_local_addresses()[3]
	elif OS.get_name() == "Android":
		mi_ip = IP.get_local_addresses()[0]
	else :
		mi_ip = IP.get_local_addresses()[3]
	
	for ip in IP.get_local_addresses():
		if ip.begins_with("192.168.") and not ip.ends_with(".1"):
			mi_ip = ip


func crear_servidor():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PEERS)
	get_tree().network_peer = peer
	
	mi_id = get_tree().get_network_unique_id()


func crear_cliente():
	var peer = NetworkedMultiplayerENet.new()
	peer.create_client(servidor_ip, SERVER_PORT)
	get_tree().network_peer = peer
	
	mi_id = get_tree().get_network_unique_id()


func _player_conectado(id):
	print("El peer " + str(id) + " se a conectado al servidor")
	
	rpc_id(id, "instanciar_peer",InfoPlayers.mi_info)


func _player_desconectado(id):
	print("El peer " + str(id) + " se a desconectado al servidor")
	
	UiNetwork.eliminar_player(id)
	InfoPlayers.players_info.erase(id)

func _coneccion_exitosa_al_servidor():
	print("Me conecte exitosamente al servidor")

func _coneccion_fallida_al_servidor():
	print("No pude conectarme al servidor")

func _desconectado_del_servidor():
	print("Me desconecte del servidor")
	
	UiNetwork.reiniciar_ui_network()


func instanciar_mi_player(id, nom_player, vida):
	UiNetwork.aniadir_player(id, nom_player, vida)
	InfoPlayers.mi_info["nombre"] = nom_player
	InfoPlayers.mi_info["vida"] = vida


remote func instanciar_peer(info):
#	yield(get_tree().create_timer(0.5),"timeout")
	var id_mensajero = get_tree().get_rpc_sender_id()
	UiNetwork.aniadir_player(id_mensajero, info["nombre"], info["vida"])
	InfoPlayers.players_info[id_mensajero] = info


remotesync func pre_configurar_juego():
	UiNetwork.visible = false
	get_tree().set_pause(true)

	var mi_player = player.instance()
	mi_player.set_name(str(Network.mi_id))
	mi_player.set_network_master(Network.mi_id)
	mi_player.mostrar_datos(InfoPlayers.mi_info)
	Mundo.get_node("Players").add_child(mi_player)

	# Load other players
	for p in InfoPlayers.players_info:
		var otro_player = player.instance()
		otro_player.set_name(str(p))
		otro_player.set_network_master(p)
		otro_player.mostrar_datos(InfoPlayers.players_info[p])
		Mundo.get_node("Players").add_child(otro_player)
	
	print("termine PRE_CONFIGURAR_JUEGO")
	rpc_id(1, "precofiguracion_terminada")

remotesync func precofiguracion_terminada():
	print("VERIFICANDO JUEGAODRES TEMINADOS")
	var player_conf = get_tree().get_rpc_sender_id()
	
	players_configurados.append(player_conf)
	print(players_configurados.size())
	print(InfoPlayers.players_info.size())
	print(InfoPlayers.players_info)
	
	if players_configurados.size() == InfoPlayers.players_info.size()+1:
		rpc("post_configure_game")
	
	
remotesync func post_configure_game():
	if 1 == get_tree().get_rpc_sender_id():
		get_tree().set_pause(false)
		print("INICIANDO JUEGO")
	
