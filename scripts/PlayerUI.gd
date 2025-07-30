extends Control

@onready var player_name: Label = $PanelContainer/MarginContainer/VBoxContainer/PlayerName
@onready var count: Label = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Count

#only allow set player to be assigned once
var assignedPlayer : Player:
	set(value):
		if assignedPlayer == null:
			assignedPlayer = value;
			
func _ready() -> void:
	update_ui();
	player_name.text = assignedPlayer.playerName;
	Events.updated_escape_tickets.connect(_on_player_ticket_count_update);
			
func update_ui():
	count.text = str(assignedPlayer.getEscapeTicketCount());

func _on_player_ticket_count_update(player: Player):
	#only call update when the assigned player is updated
	if player == assignedPlayer:
		update_ui();
