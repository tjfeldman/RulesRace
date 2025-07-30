extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;
@onready var dice : Sprite2D = $Dice;
@onready var special_dice: Sprite2D = $SpecialDice
@onready var hud: CanvasLayer = $HUD

#Player Manager
@export var players : Array[Node2D];

#Turn Manager
enum TurnState {
	LOADING, #Game is Loading
	START, #Start of Turn Triggers
	STANDBY, #Wait for Start of Turn Triggers
	ROLL, #Player can Roll
	WAIT, #Wait for Roll Triggers
	END #End of Player's Turn
};
var currentTurnState : TurnState = TurnState.LOADING;
var currentPlayerTurn : int = 0 :
	set(value):
		#if the current player turn is set over the size of players, set it to 0
		if value == players.size():
			value = 0;
		currentPlayerTurn = value;

#TODO: Move to state manager
var _asked : bool = false;

func _ready() -> void:
	print(currentTurnState);
	#connect to events
	Events.office_choice_selected.connect(_on_office_choice_selected);
	Events.escape_jail_with_ticket.connect(_on_escape_with_ticket);
	
	#add UI to HUD
	var playerUI = preload("res://scenes/playerUI.tscn");
	var ui = playerUI.instantiate();
	ui.assignedPlayer = player;
	hud.add_child(ui);
	
	#start game
	currentTurnState = TurnState.START;
	
func _process(delta: float) -> void:
	if currentTurnState != TurnState.LOADING:
		handleTurnState();
				
func handleTurnState():
	var p = players[currentPlayerTurn];
	if currentTurnState == TurnState.START:
		if p.isInJail() and player.hasEscapeTicket():
			promptForEscapeTicketInJail();
		else:
			moveToRollState();
	if currentTurnState == TurnState.END:
		currentTurnState = TurnState.START;
			
func promptForEscapeTicketInJail():
	currentTurnState = TurnState.STANDBY;
	var escapeChoiceBox = preload("res://scenes/escapeConfirm.tscn");
	var choiceBox = escapeChoiceBox.instantiate();
	add_child(choiceBox);
	
func moveToRollState():
	currentTurnState = TurnState.ROLL;
	enable_die();
	
func _on_dice_has_rolled(type: Dice.Type, roll: Variant) -> void:
	#If currentTurnState is Roll, then move to Wait state
	if currentTurnState == TurnState.ROLL:
		currentTurnState = TurnState.WAIT;
		
	match roll:
		"Jail":
			await player.sendToJail();
			currentTurnState = TurnState.END;
		"Escape":
			await player.escapeFromJail();
			currentTurnState = TurnState.END;
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
					pass;
				elif type == Dice.Type.SPECIAL:
					await get_tree().create_timer(0.5).timeout;
			currentTurnState = TurnState.END;
	
func _on_office_choice_selected(type : Events.OfficeChoice):
	match type:
		Events.OfficeChoice.Ticket:
			player.addEscapeTicket();
			currentTurnState = TurnState.END;
		Events.OfficeChoice.Dice:
			enable_special_die();
		Events.OfficeChoice.Rule:
			print("Player changes group rule");
			currentTurnState = TurnState.END;
			
func _on_escape_with_ticket(choice: bool):
	if choice:
		player.removeEscapeTicket();
		player.escapeFromJail();
	moveToRollState();

func enable_die():
	dice.canClick = true;
	dice.visible = true;
	special_dice.canClick = false; 
	special_dice.visible = false;
	
func enable_special_die():
	dice.canClick = false;
	dice.visible = false;
	special_dice.canClick = true; 
	special_dice.visible = true;
