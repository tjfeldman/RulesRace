extends Node2D

@onready var piece : Sprite2D = $PlayerPiece;

var playerMoveSpeed: float = 0.33;

var _boardPosition : int = 0;
var _inJail : bool = false;

func getBoardPosition():
	return _boardPosition;
	
func setBoardPosition(pos: int):
	_boardPosition = pos;
	
func movePlayer(newPos: Vector2, moveSpeed = playerMoveSpeed):
	var tween =  create_tween();
	tween.tween_property(piece, "position", newPos, moveSpeed);
	await tween.finished;
	
func sendToJail(jailPosition:Vector2):
	if !_inJail:
		await movePlayer(jailPosition, playerMoveSpeed * 3);
		_inJail = true;
		
func escapeFromJail(boardPosition:Vector2):
	if _inJail:
		await movePlayer(boardPosition, playerMoveSpeed * 3);
		_inJail = false;

func isInJail():
	return _inJail;
