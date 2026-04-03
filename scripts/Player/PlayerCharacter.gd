extends Node2D
class_name Player

@export var playerName: String = "Player";
@onready var piece : Sprite2D = $PlayerPiece;

#set the game board once
var board : Gameboard = null :
	set(value):
		if board == null:
			board = value;
var board_offset: int = -1:
	set(value):
		if board_offset == -1:
			board_offset = value;
var playerMoveSpeed: float = 0.33;
var _x_offsets = [-24, 0, 24];

#private variables
#TODO: Might be cleaner as a class
var _escape_tickets : int = 0:
	set(value):
		#Update value and then emit signal
		_escape_tickets = value;
		Events.emit_signal("updated_escape_tickets", self);
		
var _board_position : int = 0;
var _in_jail : bool = false;
var _finished : bool = false;
var _personal_rule: PersonalRule = PersonalRule.get_random_personal_rule();

#TODO: refactor name convention to follow snake_case
func getBoardPosition() -> int:
	return _board_position;
	
func hasEscapeTicket() -> bool:
	return _escape_tickets > 0;
	
func getEscapeTicketCount() -> int:
	return _escape_tickets;
	
func addEscapeTicket() -> void:
	_escape_tickets += 1;
	
func removeEscapeTicket() -> void:
	_escape_tickets -= 1;
	
func getPersonalRule() -> PersonalRule:
	return _personal_rule;
	
func hasFinished() -> bool:
	return _finished;
	
func _movePlayer(newPos: Vector2, moveSpeed = playerMoveSpeed):
	#TODO: Should be calculated by the board based on pieces on tile
	newPos.x += _x_offsets[board_offset];
	var tween =  create_tween();
	tween.tween_property(piece, "position", newPos, moveSpeed);
	await tween.finished;
	
func movePlayerXSpaces(x: int):
	while x != 0:
		if x > 0:
			await _movePlayerForward();
			x -= 1;
		else:
			await _movePlayerBackward();
			x += 1;
	Events.emit_signal("player_moved");
	
func moveToPlayer(player: Player):
	var dist = player.getBoardPosition() - _board_position;
	while dist != 0:
		if dist > 0:
			await _movePlayerForward();
			dist -= 1;
		else:
			await _movePlayerBackward();
			dist += 1;
	Events.emit_signal("player_moved");
	
func _movePlayerForward():
	#prevent movement if player is in jail or has finished
	if !_in_jail and !_finished:
		_board_position += 1;
		var targetTile = board.getTilePosition(_board_position);
		await _movePlayer(targetTile);
		
		#check if player reached goal
		if board.isGoalSpace(_board_position):
			_finished = true;
			Events.emit_signal("player_reached_goal", self);
			
func _movePlayerBackward():
	if !_in_jail and _board_position > 0:
		_board_position -= 1;
		var targetTile = board.getTilePosition(_board_position);
		await _movePlayer(targetTile);
	
func sendToJail():
	if !_in_jail:
		await _movePlayer(board.getJailPosition(), playerMoveSpeed * 3);
		_in_jail = true;
		Events.emit_signal("action_trigger", EventPair.new(self, EventPair.ActionChecks.JAIL));
		return true;
	return false;
		
#returns true if player escaped from jail and should roll again
func escapeFromJail():
	if _in_jail:
		await _movePlayer(board.getTilePosition(_board_position), playerMoveSpeed * 3);
		_in_jail = false;
		return true;
	return false;

func isInJail():
	return _in_jail;
	
func on_office_space():
	return !_in_jail and board.isOfficeSpace(_board_position);
	
func is_sharing_space_with_player(player: Player, condition: PersonalRules.Condition):
	#if the condition is sent to jail or player is not in jail, then we just to compare board position
	if condition == PersonalRules.Condition.SENT_JAIL || !_in_jail:
		return _board_position == player.getBoardPosition();
	#otherwise then we just need to check if both players are in jail
	else: 
		return _in_jail and player.isInJail();
	
func isBot():
	return self is BotPlayer;
	
"""
Override Functions
"""
func setActionOptions(_options: Dictionary[Actions.Type, Callable]) -> void:
	push_error("PlayerCharacter.setActionOptions needs to be overridden");
	
func selectOfficeReward() -> OfficeChoice.Option:
	push_error("PlayerCharacter.selectOfficeReward needs to be overridden");
	return OfficeChoice.Option.NONE;
	
func confirmGroupEffect() -> GroupRules.Effect:
	push_error("PlayerCharacter.confirmGroupEffect needs to be overridden");
	return GroupRules.Effect.NONE;

func selectTargetPlayer(_playerlist: Array[Player], _is_can_rule) -> Player:
	push_error("PlayerCharacter.selectTargetPlayer needs to be overridden");
	return null;
