extends Control
class_name ActionManager

@onready var escape: Button = $PanelContainer/MarginContainer/VBoxContainer/Escape
@onready var dice: Button = $PanelContainer/MarginContainer/VBoxContainer/Dice
@onready var special: Button = $PanelContainer/MarginContainer/VBoxContainer/Special
@onready var group: Button = $PanelContainer/MarginContainer/VBoxContainer/Group
@onready var end: Button = $PanelContainer/MarginContainer/VBoxContainer/End

"""
When a player's turn starts, they roll a die.
Before they roll this die, they can use an escape ticket or group rule.
Once they roll the standard die, their turn ends and they cannot use escape tickets or group rules.
"""

enum TurnState {
	LOADING, #Game is Loading
	START, #Start of Turn, player has a die to roll
	ROLLING, #The player is rolling their die.
	CAN_ROLL, #The player has additional dice to roll
	END, #Player is at end of their turn, can no longer do anything else
	OVER, #Game is over
};

#Static Fields
static var _currentTurnState: TurnState = TurnState.LOADING:
	set(value):
			#Update value and then emit signal
			_currentTurnState = value;
			#Events.emit_signal("turn_state_changed");
static func getCurrentTurnState(): return _currentTurnState;

var _hasNormalDie: bool = false;
var _hasSpecialDie: bool = false;
var _currentGroupAction: GroupAction = GroupAction.new();

#TODO: Maybe change to Static Class

func _ready() -> void:
	#connect events
	Events.start_turn.connect(_next_turn);
	Events.player_moved.connect(_player_moved);
	Events.gain_die_roll.connect(_gain_die);
	Events.forfeit_die_roll.connect(_forfeit_die);
	Events.group_rule_finished.connect(_show_actions);
	Events.update_group_action.connect(_update_group_action);
		
func _next_turn():
	if _currentTurnState != TurnState.OVER:
		_hasNormalDie = true;
		_hasSpecialDie = false;
		_currentTurnState = TurnState.START;
		_show_actions();
		if PlayerManager.getCurrentTurnPlayer().isBot():
			self.visible = false;
			_bot_turn_action();
		else:
			self.visible = true;
	
func _player_moved():
	#remove the extra dice the player has one
	if _hasNormalDie or _hasSpecialDie:
		_currentTurnState = TurnState.CAN_ROLL;
	#otherwise their turn is over
	else:
		_currentTurnState = TurnState.END;
	_show_actions();
	if PlayerManager.getCurrentTurnPlayer().isBot():
		_bot_turn_action();
			
func _gain_die(special_die: bool):
	if special_die:
		_hasSpecialDie = true;
	else:
		_hasNormalDie = true;
	_currentTurnState = TurnState.CAN_ROLL;
	_show_actions();
			
func _on_escape_pressed() -> void:
	_disable_all_actions();
	escape.visible = false;
	await _player_escapes_jail();
	_show_actions();

func _on_dice_pressed() -> void:
	_hasNormalDie = false;
	_disable_all_actions();
	_currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", false);
	
func _on_special_pressed() -> void:
	_hasSpecialDie = false;
	_disable_all_actions();
	_currentTurnState = TurnState.ROLLING;
	Events.emit_signal("roll_die_action", true);
	
func _on_group_pressed() -> void:
	#grab the current scene to send with the perform action
	_disable_all_actions();
	_currentGroupAction.performAction(PlayerManager.getCurrentTurnPlayer());
	
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
	var currentTurnPlayer = PlayerManager.getCurrentTurnPlayer();
	return _currentTurnState == TurnState.START and currentTurnPlayer.isInJail() and currentTurnPlayer.hasEscapeTicket();
	
func _player_can_use_group_rule():
	#Players can only use the group rule if the following are true
	#The group rule is valid
	var isValid = _currentGroupAction.isValid();
	
	#The player can pay for the group rule
	var canPay = _currentGroupAction.canPay(PlayerManager.getCurrentTurnPlayer());
	
	#If the rule grants special dice, the player does not already have a special die
	if _currentGroupAction.isGrantSpecialDie():
		return isValid and canPay and not _hasSpecialDie;
	#if the rule grants a reroll, the player does not have a normal die
	elif _currentGroupAction.isGrantReroll():
		return isValid and canPay and not _hasNormalDie
	#otherwise just check if it is not end of turn
	return isValid and canPay;
	
func _player_escapes_jail():
	var currentTurnPlayer = PlayerManager.getCurrentTurnPlayer();
	#TODO: Move Turn Status update to this function?
	Events.emit_signal("escape_jail_action"); 
	currentTurnPlayer.removeEscapeTicket();
	await currentTurnPlayer.escapeFromJail();
	
#BOT ACTIONS
func _bot_turn_action():
	if _currentTurnState == TurnState.OVER:
		return; #do nothing if game is over
		
	await get_tree().create_timer(0.5).timeout;
	#At the start of a bot's turn if it's in jail and has an escape ticket, it will escape
	if _player_can_escape_jail():
		await _player_escapes_jail();
		await get_tree().create_timer(0.5).timeout;
		
	#then the bot will roll their dice
	if special.visible:
		_on_special_pressed();
	elif dice.visible:
		_on_dice_pressed();
	else:
		_on_end_pressed();	

func _forfeit_die():
	_currentTurnState = TurnState.END;
		
func _show_actions():
	_enable_all_actions();
	if _currentTurnState == TurnState.OVER:
		self.visible = false;
	else:
		var endOfTurn = _currentTurnState == TurnState.END;
		
		escape.visible = _player_can_escape_jail();
		dice.visible = _hasNormalDie and not _hasSpecialDie and not endOfTurn;
		special.visible = _hasSpecialDie and not endOfTurn;
		group.visible =  _player_can_use_group_rule();
		end.visible = endOfTurn;
	
func _update_group_action(groupAction: GroupAction):
	_currentGroupAction = groupAction;
	group.text = "Group Rule %s" % groupAction.getCostString();

func playerFinished():
	self.visible = false;
	_currentTurnState = TurnState.OVER;
