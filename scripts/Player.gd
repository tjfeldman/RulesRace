extends Node2D

@onready var piece : Sprite2D = $PlayerPiece;
@onready var board : Node2D = $"../Board";
var playerMoveSpeed: float = 0.33;

#private variables
var _escapeTickets : int = 0;
var _boardPosition : int = 0;
var _inJail : bool = false;

func getBoardPosition():
	return _boardPosition;
	
func getEscapeTicketCount():
	return _escapeTickets;
	
func addEscapeTicket():
	_escapeTickets += 1;
	
func removeEscapeTicket():
	_escapeTickets -= 1;
	
func _movePlayer(newPos: Vector2, moveSpeed = playerMoveSpeed):
	if newPos != null:
		var tween =  create_tween();
		tween.tween_property(piece, "position", newPos, moveSpeed);
		await tween.finished;
	
func movePlayerForward():
	#prevent movement if player is in jail
	if !_inJail:
		_boardPosition += 1;
		var targetTile = board.getTilePosition(_boardPosition);
		await _movePlayer(targetTile);
	
func sendToJail():
	if !_inJail:
		await _movePlayer(board.getJailPosition(), playerMoveSpeed * 3);
		_inJail = true;
		
func escapeFromJail():
	if _inJail:
		await _movePlayer(board.getTilePosition(_boardPosition), playerMoveSpeed * 3);
		_inJail = false;

func isInJail():
	return _inJail;
