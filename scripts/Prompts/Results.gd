extends Node

@onready var players_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PlayersPanel/PlayersList


func _ready() -> void:
	var finished = PlayerManager.getWinningOrder();
	for i in range(finished.size()):
		var player = finished[i];
		var label = Label.new();
		label.text = "%s - %s"%[player.playerName, _get_place(i+1)];
		players_list.add_child(label);
		
func _get_place(place):
	match place:
		1:
			return "1st 🥇";
		2:
			return "2nd 🥈";
		3:
			return "3rd 🥉";
		_:
			return "%sth"%place;


func _on_button_pressed() -> void:
	get_tree().quit();
