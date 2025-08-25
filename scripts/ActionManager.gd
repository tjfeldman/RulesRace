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
	CAN_ROLL, #Player can roll
	ROLLING, #Player is Rolling
	END, #Player is at end of their turn
	OVER, #Game is over
};

#Static Fields
static var _currentTurnState: TurnState = TurnState.LOADING;
static var _currentTurnPlayer : Player;
static func getCurrentTurnState(): return _currentTurnState;
static func getCurrentTurnPlayer(): return _currentTurnPlayer;

var _currentDieToRoll = Dice.Type.NONE;

func _ready() -> void:
	#connect events
	Events.start_turn.connect(_next_turn);
	Events.player_moved.connect(_player_moved);
	Events.gain_die_roll.connect(_gain_die);
	Events.office_choice_picked.connect(_office_choice);
	
func _next_turn(player: Player):
	if _currentTurnState != TurnState.OVER:
		_currentTurnPlayer = player;
		_currentDieToRoll = Dice.Type.NORMAL;
		_currentTurnState = TurnState.START;
		_show_actions();
		if player.isBot():
			self.visible = false;
			_bot_turn_action();
		else:
			self.visible = true;
	
func _player_moved(escapedFromPrison: bool):
	if escapedFromPrison:
		_currentDieToRoll = Dice.Type.NORMAL;
	_updateTurnState();
	if _currentTurnPlayer.isBot():
		_bot_turn_action();

func _office_choice(type : OfficeChoice.Option):
	match type:
		OfficeChoice.Option.TICKET:
			_currentTurnPlayer.addEscapeTicket();
		OfficeChoice.Option.DIE:
			_currentDieToRoll = Dice.Type.SPECIAL;
			
func _gain_die(special_die: bool):
	if special_die:
		_currentDieToRoll = Dice.Type.SPECIAL;
	else:
		_currentDieToRoll = Dice.Type.NORMAL;
	_updateTurnState();
			
func _on_escape_pressed() -> void:
	_disable_all_actions();
	escape.visible = false;
	await _player_escapes_jail();
	_enable_all_actions();

func _on_dice_pressed() -> void:
	_currentDieToRoll = Dice.Type.NONE;
	_disable_all_actions();
	_currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", false);
	
func _on_special_pressed() -> void:
	_currentDieToRoll = Dice.Type.NONE;
	_disable_all_actions();
	_currentTurnState = TurnState.ROLLING;
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
	
#player can only escape jail with ticket at start of turn while in jail with at least 1 escape ticket	
func _player_can_escape_jail():
	return _currentTurnState == TurnState.START and _currentTurnPlayer.isInJail() and _currentTurnPlayer.hasEscapeTicket();
	
func _player_escapes_jail():
	Events.emit_signal("escape_jail_action");
	_currentTurnPlayer.removeEscapeTicket();
	await _currentTurnPlayer.escapeFromJail();
	
#BOT ACTIONS
func _bot_turn_action():
	await get_tree().create_timer(0.5).timeout;
	#At the start of a bot's turn if it's in jail and has an escape ticket, it will escape
	if _player_can_escape_jail():
		await _player_escapes_jail();
		await get_tree().create_timer(0.5).timeout;
		
	#then the bot will roll their dice
	if _currentDieToRoll == Dice.Type.SPECIAL:
		_on_special_pressed();
	elif _currentDieToRoll == Dice.Type.NORMAL:
		_on_dice_pressed();
	else:
		_on_end_pressed();
		
func _updateTurnState():
	if _currentTurnState == TurnState.OVER:
		return;
		
	_show_actions();
	if _currentDieToRoll == Dice.Type.NONE:
		_currentTurnState = TurnState.END;
	else:
		_currentTurnState = TurnState.CAN_ROLL;
		
func _show_actions():
	_enable_all_actions();
	escape.visible = _player_can_escape_jail();
	dice.visible = _currentDieToRoll == Dice.Type.NORMAL;
	special.visible = _currentDieToRoll == Dice.Type.SPECIAL;
	group.visible = false;
	end.visible = _currentDieToRoll == Dice.Type.NONE;

func playerFinished():
	self.visible = false;
	_currentTurnState = TurnState.OVER;
