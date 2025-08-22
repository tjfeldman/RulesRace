extends Control
class_name ActionManager

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

#Static Fields
static var _currentTurnState: TurnState = TurnState.LOADING;
static var _currentTurnPlayer : Player;
static func getCurrentTurnState(): return _currentTurnState;
static func getCurrentTurnPlayer(): return _currentTurnPlayer;


func _ready() -> void:
	#connect events
	Events.start_turn.connect(_next_turn);
	Events.player_moved.connect(_player_moved);
	Events.office_choice_selected.connect(_office_choice);
	Events.declined_rule_effect.connect(_no_effect_used)
	
func _next_turn(player: Player):
	_currentTurnPlayer = player;
	_updateTurnState(TurnState.START);
	if (player.isBot()):
		self.visible = false;
		_bot_start_turn();
	else:
		self.visible = true;
	
func _player_moved(movement: Events.Movements):
	match movement:
		Events.Movements.Escape:
			_updateTurnState(TurnState.REROLL);
		Events.Movements.Office:
			_updateTurnState(TurnState.SELECTING);
		Events.Movements.Rule:
			_updateTurnState(TurnState.SELECTING);
		Events.Movements.Goal:
			_updateTurnState(TurnState.OVER);
			self.visible = false;
		_:
			_updateTurnState(TurnState.END);
	_check_for_bot_action();
	

func _office_choice(type : Events.OfficeChoice):
	match type:
		Events.OfficeChoice.Ticket:
			_currentTurnPlayer.addEscapeTicket();
			_updateTurnState(TurnState.END);
		Events.OfficeChoice.Dice:
			_updateTurnState(TurnState.SPECIAL);
	_check_for_bot_action();
	
func _no_effect_used():
	_updateTurnState(TurnState.END);
	_check_for_bot_action();
			
func _on_escape_pressed() -> void:
	_disable_all_actions();
	escape.visible = false;
	await _player_escapes_jail();
	_enable_all_actions();

func _on_dice_pressed() -> void:
	_updateTurnState(TurnState.ROLLING);
	Events.emit_signal("roll_die_action", false);
	
func _on_special_pressed() -> void:
	_updateTurnState(TurnState.ROLLING);
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
	return _currentTurnPlayer.isInJail() && _currentTurnPlayer.hasEscapeTicket();
	
func _player_escapes_jail():
	Events.emit_signal("escape_jail_action");
	_currentTurnPlayer.removeEscapeTicket();
	await _currentTurnPlayer.escapeFromJail();
	
#BOT ACTIONS
func _bot_start_turn():
	await get_tree().create_timer(0.5).timeout;
	#At the start of a bot's turn if it's in jail and has an escape ticket, it will escape
	if _player_can_escape_jail():
		await _player_escapes_jail();
		await get_tree().create_timer(0.5).timeout;
	#then the bot will roll their dice
	_updateTurnState(TurnState.ROLLING);
	Events.emit_signal("roll_die_action", false);
	
func _bot_after_roll():
	match _currentTurnState:
		TurnState.REROLL:
			#if bot has reroll, they will reroll
			_updateTurnState(TurnState.ROLLING);
			Events.emit_signal("roll_die_action", false);
		TurnState.SPECIAL:
			#if bot has special die, they will roll it
			_updateTurnState(TurnState.ROLLING);
			Events.emit_signal("roll_die_action", true);
		TurnState.END:
			#if it's the end of the bots turn, they will end
			Events.emit_signal("end_turn");
			
func _check_for_bot_action():
	if _currentTurnPlayer.isBot() && _currentTurnState != TurnState.SELECTING:
		await get_tree().create_timer(0.5).timeout;
		_bot_after_roll();
			
#Turn State Update Manager
func _updateTurnState(newState: TurnState):
	match(newState):
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
	_currentTurnState = newState;
