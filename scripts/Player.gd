extends Node2D

class_name Player

@export var playerName: String = "Player";
@export var bot : bool = false;

@onready var piece : Sprite2D = $PlayerPiece;
@onready var board : Node2D = $"../Board";
var playerMoveSpeed: float = 0.33;

#private variables
var _escapeTickets : int = 0:
	set(value):
		#Update value and then emit signal
		_escapeTickets = value;
		Events.emit_signal("updated_escape_tickets", self);
		
var _boardPosition : int = 0;
var _inJail : bool = false;

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
	
func _movePlayer(newPos: Vector2, moveSpeed = playerMoveSpeed):
	#TODO: Should be calculated by the board based on pieces on tile
	if bot:
		newPos.x += 12;
	else:
		newPos.x -= 12;
	var tween =  create_tween();
	tween.tween_property(piece, "position", newPos, moveSpeed);
	await tween.finished;
	
func movePlayerForward():
	#prevent movement if player is in jail
	if !_inJail:
		_boardPosition += 1;
		var targetTile = board.getTilePosition(_boardPosition);
		await _movePlayer(targetTile); #TODO: Better Handling to prevent moving past goal
	
func sendToJail():
	if !_inJail:
		await _movePlayer(board.getJailPosition(), playerMoveSpeed * 3);
		_inJail = true;
		
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
