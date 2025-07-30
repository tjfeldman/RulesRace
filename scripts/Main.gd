extends Node2D

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
	END, #End of Player's Turn
	SWITCHING, #Switching Player's Turn
};
var currentTurnState : TurnState = TurnState.LOADING;
var currentPlayerTurn : int = 0 :
	set(value):
		#if the current player turn is set over the size of players, set it to 0
		if value == players.size():
			value = 0;
		currentPlayerTurn = value;

func _ready() -> void:
	#connect to events
	Events.office_choice_selected.connect(_on_office_choice_selected);
	Events.escape_jail_with_ticket.connect(_on_escape_with_ticket);
	
	#add UI to HUD
	var offset = 0;
	for player in players:
		var playerUI = preload("res://scenes/playerUI.tscn");
		var ui = playerUI.instantiate();
		ui.assignedPlayer = player;
		hud.add_child(ui);
		ui.position += Vector2(0, offset);
		offset+= ui.size.y + 16;
	
	#start game
	currentTurnState = TurnState.START;
	
func _process(_delta: float) -> void:
	if currentTurnState != TurnState.LOADING:
		handleTurnState();
				
func handleTurnState():
	var currentPlayer = players[currentPlayerTurn];
	if currentTurnState == TurnState.START:
		if currentPlayer.isInJail() and currentPlayer.hasEscapeTicket():
			promptForEscapeTicketInJail(currentPlayer);
		else:
			moveToRollState(currentPlayer);
	if currentTurnState == TurnState.END:
		currentTurnState = TurnState.SWITCHING;
		currentPlayerTurn += 1;
		await get_tree().create_timer(0.5).timeout;
		currentTurnState = TurnState.START;
			
func promptForEscapeTicketInJail(player: Player):
	currentTurnState = TurnState.STANDBY;
	if !player.isBot():
		var escapeChoiceBox = preload("res://scenes/escapeConfirm.tscn");
		var choiceBox = escapeChoiceBox.instantiate();
		add_child(choiceBox);
	else:
		#Bot will always use an escape ticket to escape
		self._on_escape_with_ticket(true);
		pass;
		
func promptForOfficeReward(player: Player):
	if !player.isBot():
		var officeChoiceBox = preload("res://scenes/officeChoice.tscn");
		var choiceBox = officeChoiceBox.instantiate();
		add_child(choiceBox);
	else:
		#TODO Right now there is no mechanic to change group rule so bot can't chose it right now
		var choices: Array[Events.OfficeChoice] = [Events.OfficeChoice.Ticket, Events.OfficeChoice.Dice];
		var picked = choices.pick_random();
		print("Bot picked %s" % picked);
		self._on_office_choice_selected(picked);
		pass;
	
func moveToRollState(player: Player):
	currentTurnState = TurnState.ROLL;
	enable_die(player);
	
func _on_dice_has_rolled(type: Dice.Type, roll: Variant) -> void:
	#If currentTurnState is Roll, then move to Wait state
	if currentTurnState == TurnState.ROLL:
		currentTurnState = TurnState.WAIT;
		
	var currentPlayer = players[currentPlayerTurn];
	match roll:
		"Jail":
			await currentPlayer.sendToJail();
			currentTurnState = TurnState.END;
		"Escape":
			if await currentPlayer.escapeFromJail():
				#when player escapes from jail, they get to roll again
				enable_die(currentPlayer);
			else:
				currentTurnState = TurnState.END;
		_:
			if !currentPlayer.isInJail():
				while roll > 0:
					await currentPlayer.movePlayerForward();
					roll -= 1;
				
				#check if the tile landed on is an office space
				if board.isOfficeSpace(currentPlayer.getBoardPosition()):
					promptForOfficeReward(currentPlayer);
					return; #skip swapping turn state to end
			currentTurnState = TurnState.END;
	
func _on_office_choice_selected(type : Events.OfficeChoice):
	var currentPlayer = players[currentPlayerTurn];
	match type:
		Events.OfficeChoice.Ticket:
			currentPlayer.addEscapeTicket();
			currentTurnState = TurnState.END;
		Events.OfficeChoice.Dice:
			enable_special_die(currentPlayer);
		Events.OfficeChoice.Rule:
			print("Player changes group rule");
			currentTurnState = TurnState.END;
			
func _on_escape_with_ticket(choice: bool):
	var currentPlayer = players[currentPlayerTurn];
	if choice:
		currentPlayer.removeEscapeTicket();
		currentPlayer.escapeFromJail();
	moveToRollState(currentPlayer);

func enable_die(player: Player):
	dice.visible = true;
	special_dice.canClick = false; 
	special_dice.visible = false;
	if !player.isBot():
		dice.canClick = true;
	else:
		#give bot slight delay
		await get_tree().create_timer(0.5).timeout;
		dice.rollDie();	
	
func enable_special_die(player: Player):
	dice.canClick = false;
	dice.visible = false;
	special_dice.visible = true;
	if !player.isBot():
		special_dice.canClick = true; 
	else:
		#give bot slight delay
		await get_tree().create_timer(0.5).timeout;
		special_dice.rollDie();	
