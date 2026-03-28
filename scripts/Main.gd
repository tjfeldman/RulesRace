extends Node2D

@onready var hud: CanvasLayer = $HUD
@onready var turn_manager: Node = $TurnManager
#TODO: Send turn_status label to other Managers so they can update the status too
@onready var turn_status: Label = $TurnManager/TurnStatus

func _ready() -> void:
	#start game
	call_deferred("_start_game");
	
func _start_game():
	#add UI to HUD
	var offset = 0;
	#TODO: Should be handled elsewhere
	for player in PlayerManager.getPlayers():
		var playerUI = preload("res://scenes/playerUI.tscn");
		var ui = playerUI.instantiate();
		ui.assignedPlayer = player;
		hud.add_child(ui);
		ui.position += Vector2(0, offset);
		offset+= ui.size.y + 16;
	
	#turn_status.text = "%s's Turn" % PlayerManager.getCurrentTurnPlayer().playerName;
	#Events.emit_signal("start_turn");
	turn_manager.startRace();	
