extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;
@onready var dice : Sprite2D = $Dice;
@onready var special_dice: Sprite2D = $SpecialDice
@onready var hud: CanvasLayer = $HUD

#TODO: Move to state manager
var _asked : bool = false;

func _ready() -> void:
	#connect to events
	Events.office_choice_selected.connect(_on_office_choice_selected);
	Events.escape_jail_with_ticket.connect(_on_escape_with_ticket);
	
	#add UI to HUD
	var playerUI = preload("res://scenes/playerUI.tscn");
	var ui = playerUI.instantiate();
	ui.assignedPlayer = player;
	hud.add_child(ui);
	
	#enable dice
	dice.canClick = true;
	
func _process(delta: float) -> void:
	if (!_asked && player.isInJail() and player.hasEscapeTicket()):
		_asked = true;
		#TODO: Handle in state manager
		dice.canClick = false;
		var escapeChoiceBox = preload("res://scenes/escapeConfirm.tscn");
		var choiceBox = escapeChoiceBox.instantiate();
		add_child(choiceBox);

func _on_dice_has_rolled(type: Dice.Type, roll: Variant) -> void:
	#reset asked value after rolling
	_asked = false;
	match roll:
		"Jail":
			await player.sendToJail();
			enable_die();
		"Escape":
			await player.escapeFromJail();
			enable_die();
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
				elif type == Dice.Type.SPECIAL:
					#wait 1 second before enabling the die again
					await get_tree().create_timer(1.0).timeout
					enable_die();
				else:
					enable_die();
			else:
				enable_die();
	
func _on_office_choice_selected(type : Events.OfficeChoice):
	match type:
		Events.OfficeChoice.Ticket:
			player.addEscapeTicket();
			enable_die();
		Events.OfficeChoice.Dice:
			enable_special_die();
		Events.OfficeChoice.Rule:
			print("Player changes group rule");
			enable_die();
			
func _on_escape_with_ticket(choice: bool):
	if choice:
		player.removeEscapeTicket();
		player.escapeFromJail();
	enable_die();

#TODO: Handle in state manager
func enable_die():
	dice.canClick = true;
	dice.visible = true;
	special_dice.canClick = false; 
	special_dice.visible = false;
	
#TODO: Handle in state manager
func enable_special_die():
	dice.canClick = false;
	dice.visible = false;
	special_dice.canClick = true; 
	special_dice.visible = true;
