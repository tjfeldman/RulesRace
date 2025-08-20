extends Control

@onready var escape: Button = $PanelContainer/MarginContainer/VBoxContainer/Escape
@onready var dice: Button = $PanelContainer/MarginContainer/VBoxContainer/Dice
@onready var special: Button = $PanelContainer/MarginContainer/VBoxContainer/Special
@onready var group: Button = $PanelContainer/MarginContainer/VBoxContainer/Group
@onready var end: Button = $PanelContainer/MarginContainer/VBoxContainer/End

enum TurnState {
	LOADING, #Game is Loading
	START, #Start of Turn
	ROLLING, #Player is Rolling
	SELECTING, #Player is selecting an option
	REROLL, #Player can reroll
	SPECIAL, #Player has special roll
	END, #Player is at end of their turn
	OVER, #Game is over
};

var currentTurnPlayer : Player;
var currentTurnState : TurnState = TurnState.LOADING :
	set(value):
		match(value):
			TurnState.START:
				_enable_all_actions();
				escape.visible = _player_can_escape_jail();
				dice.visible = true;
				special.visible = false;
				group.visible = false;
				end.visible = false;
			TurnState.ROLLING:
				_disable_all_actions();
			TurnState.SELECTING:
				_disable_all_actions();
			TurnState.REROLL:
				_enable_all_actions();
				escape.visible = false;
				dice.visible = true;
				special.visible = false;
				group.visible = false;
				end.visible = false;
			TurnState.SPECIAL:
				_enable_all_actions();
				escape.visible = false;
				dice.visible = false;
				special.visible = true;
				group.visible = false;
				end.visible = false;
			TurnState.END:
				_enable_all_actions();
				escape.visible = false;
				dice.visible = false;
				special.visible = false;
				group.visible = false;
				end.visible = true;
		currentTurnState = value;

func _ready() -> void:
	#connect events
	Events.start_turn.connect(_next_turn);
	Events.player_moved.connect(_player_moved);
	Events.office_choice_selected.connect(_office_choice);
	
func _next_turn(player: Player):
	currentTurnPlayer = player;
	currentTurnState = TurnState.START;
	if (player.isBot()):
		self.visible = false;
		_bot_start_turn();
	else:
		self.visible = true;
	
func _player_moved(movement: Events.Movements):
	match movement:
		Events.Movements.Escape:
			currentTurnState = TurnState.REROLL;
		Events.Movements.Office:
			currentTurnState = TurnState.SELECTING;
		Events.Movements.Goal:
			currentTurnState = TurnState.OVER;
			self.visible = false;
		_:
			currentTurnState = TurnState.END;
			
	if currentTurnPlayer.isBot() && currentTurnState != TurnState.SELECTING:
		await get_tree().create_timer(0.5).timeout;
		_bot_after_roll();

func _office_choice(type : Events.OfficeChoice):
	match type:
		Events.OfficeChoice.Ticket:
			currentTurnPlayer.addEscapeTicket();
			currentTurnState = TurnState.END;
		Events.OfficeChoice.Dice:
			currentTurnState = TurnState.SPECIAL;
			
	if currentTurnPlayer.isBot():
		await get_tree().create_timer(0.5).timeout;
		_bot_after_roll();
			
func _on_escape_pressed() -> void:
	_disable_all_actions();
	escape.visible = false;
	await _player_escapes_jail();
	_enable_all_actions();

func _on_dice_pressed() -> void:
	currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", false);
	
func _on_special_pressed() -> void:
	currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", true);
	
func _on_end_pressed() -> void:
	self.visible = false;
	Events.emit_signal("end_turn");
	
func _disable_all_actions():
	escape.disabled = true;
	dice.disabled = true;
	special.disabled = true;
	group.disabled = true;
	end.disabled = true;
	
func _enable_all_actions():
	escape.disabled = false;
	dice.disabled = false;
	special.disabled = false;
	group.disabled = false;
	end.disabled = false;
	
func _player_can_escape_jail():
	return currentTurnPlayer.isInJail() && currentTurnPlayer.hasEscapeTicket();
	
func _player_escapes_jail():
	Events.emit_signal("escape_jail_action");
	currentTurnPlayer.removeEscapeTicket();
	await currentTurnPlayer.escapeFromJail();
	
#BOT ACTIONS
func _bot_start_turn():
	await get_tree().create_timer(0.5).timeout;
	#At the start of a bot's turn if it's in jail and has an escape ticket, it will escape
	if _player_can_escape_jail():
		await _player_escapes_jail();
		await get_tree().create_timer(0.5).timeout;
	#then the bot will roll their dice
	currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", false);
	
func _bot_after_roll():
	match currentTurnState:
		TurnState.REROLL:
			#if bot has reroll, they will reroll
			currentTurnState = TurnState.ROLLING;
			Events.emit_signal("roll_die_action", false);
		TurnState.SPECIAL:
			#if bot has special die, they will roll it
			currentTurnState = TurnState.ROLLING;
			Events.emit_signal("roll_die_action", true);
		TurnState.END:
			#if it's the end of the bots turn, they will end
			Events.emit_signal("end_turn");
