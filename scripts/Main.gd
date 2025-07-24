extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;
@onready var dice : Sprite2D = $Dice;

#TODO: Move to state manager
var _asked : bool = false;

func _ready() -> void:
	player.addEscapeTicket();
	print(player.getEscapeTicketCount());
	
	#connect to events
	Events.office_choice_selected.connect(_on_office_choice_selected);
	Events.escape_jail_with_ticket.connect(_on_escape_with_ticket);
	
func _process(delta: float) -> void:
	if (!_asked && player.isInJail() and player.hasEscapeTicket()):
		_asked = true;
		#TODO: Handle in state manager
		dice.canClick = false;
		var escapeChoiceBox = preload("res://scenes/escapeConfirm.tscn");
		var choiceBox = escapeChoiceBox.instantiate();
		add_child(choiceBox);

func _on_dice_has_rolled(roll: Variant) -> void:
	roll = 4;
	#reset asked value after rolling
	_asked = false;
	match roll:
		"Jail":
			player.sendToJail();
			#TODO: Handle in state manager
			dice.canClick = true;
		"Escape":
			player.escapeFromJail();
			#TODO: Handle in state manager
			dice.canClick = true;
		_:
			if !player.isInJail():
				while roll > 0:
					await player.movePlayerForward();
					roll -= 1;
				
				#check if the tile landed on is an office space
				if board.isOfficeSpace(player.getBoardPosition()):
					var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
					var choiceBox = officeChoiceBox.instantiate();
					add_child(choiceBox);
				else:
					#TODO: Handle in state manager
					dice.canClick = true;
	
func _on_office_choice_selected(type : Events.OfficeChoice):
	match type:
		Events.OfficeChoice.Ticket:
			player.addEscapeTicket();
			print(player.getEscapeTicketCount());
		Events.OfficeChoice.Dice:
			print("Player rolls special die");
		Events.OfficeChoice.Rule:
			print("Player changes group rule");
	#TODO: Handle in state manager
	dice.canClick = true;
			
func _on_escape_with_ticket(choice: bool):
	if choice:
		player.removeEscapeTicket();
		player.escapeFromJail();
	#TODO: Handle in state manager
	dice.canClick = true;
