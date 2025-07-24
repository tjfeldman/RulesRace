extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;

func _ready() -> void:
	player.addEscapeTicket();
	print(player.getEscapeTicketCount());

func _on_dice_has_rolled(roll: Variant) -> void:
	match roll:
		"Jail":
			player.sendToJail();
		"Escape":
			player.escapeFromJail();
		_:
			if !player.isInJail():
				while roll > 0:
					player.movePlayerForward();
					roll -= 1;
				
				#check if the tile landed on is an office space
				if board.isOfficeSpace(player.getBoardPosition()):
					var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
					var choiceBox = officeChoiceBox.instantiate();
					add_child(choiceBox);
