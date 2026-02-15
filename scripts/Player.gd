extends Node2D

class_name Player

@export var playerName: String = "Player";
@export var bot : bool = false;

@onready var piece : Sprite2D = $PlayerPiece;
#@onready var board : Node2D = $"../Board";

#set the game board once
var board : Gameboard = null :
	set(value):
		if board == null:
			board = value;
var playerMoveSpeed: float = 0.33;

#private variables
var _escapeTickets : int = 0:
	set(value):
		#Update value and then emit signal
		_escapeTickets = value;
		Events.emit_signal("updated_escape_tickets", self);
		
var _boardPosition : int = 0;
var _inJail : bool = false;
var _finished : bool = false;

func getBoardPosition():
	return _boardPosition;
	
func hasEscapeTicket():
	return _escapeTickets > 0;
	
func getEscapeTicketCount():
	return _escapeTickets;
	
func addEscapeTicket():
	_escapeTickets += 1;
	
func removeEscapeTicket():
	_escapeTickets -= 1;
	
func hasFinished():
	return _finished;
	
func _movePlayer(newPos: Vector2, moveSpeed = playerMoveSpeed):
	#TODO: Should be calculated by the board based on pieces on tile
	if bot:
		newPos.x += 12;
	else:
		newPos.x -= 12;
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
	Events.emit_signal("player_moved", self);
	
func moveToPlayer(player: Player):
	var dist = player.getBoardPosition() - _boardPosition;
	while dist != 0:
		if dist > 0:
			await _movePlayerForward();
			dist -= 1;
		else:
			await _movePlayerBackward();
			dist += 1;
	Events.emit_signal("player_moved", self);
	
func _movePlayerForward():
	#prevent movement if player is in jail or has finished
	if !_inJail and !_finished:
		_boardPosition += 1;
		var targetTile = board.getTilePosition(_boardPosition);
		await _movePlayer(targetTile);
		
		#check if player reached goal
		if board.isGoalSpace(_boardPosition):
			_finished = true;
			Events.emit_signal("player_reached_goal", self);
			
func _movePlayerBackward():
	if !_inJail and _boardPosition > 0:
		_boardPosition -= 1;
		var targetTile = board.getTilePosition(_boardPosition);
		await _movePlayer(targetTile);
	
func sendToJail():
	if !_inJail:
		await _movePlayer(board.getJailPosition(), playerMoveSpeed * 3);
		_inJail = true;
		Events.emit_signal("player_sent_to_jail", self);
		return true;
	return false;
		
#returns true if player escaped from jail and should roll again
func escapeFromJail():
	if _inJail:
		await _movePlayer(board.getTilePosition(_boardPosition), playerMoveSpeed * 3);
		_inJail = false;
		return true;
	return false;

func isInJail():
	return _inJail;
	
func isBot():
	return bot;
