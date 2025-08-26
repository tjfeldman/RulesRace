extends CenterContainer

@onready var label: Label = $PanelContainer/MarginContainer/VBoxContainer/Label
@onready var button_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ButtonList

signal selected_player(player: Player);

func setPlayerList(players: Array[Player], canSelectNone: bool = false):
	for player in players:
		var button = Button.new();
		button.text = player.name;
		button.pressed.connect(_button_pressed.bind(player));
		button_list.add_child(button);
	if canSelectNone:
		var button = Button.new();
		button.text = "None";
		button.pressed.connect(_button_pressed.bind(null));
		button_list.add_child(button);

func _button_pressed(player: Player):
	queue_free();
	selected_player.emit(player);
