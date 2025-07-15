extends Node2D

@onready var piece : Sprite2D = $PlayerPiece;

var playerMoveSpeed: float = 0.33;

var _boardPosition : int = 0;
var _inJail : bool = false;

func getBoardPosition():
	return _boardPosition;
	
func movePlayer(spaces: int, moves: Array[Node]):
	for tile in moves:
		print("Moving to Tile %s" % tile);
		var tween =  create_tween();
		tween.tween_property(piece, "position", tile.global_position, playerMoveSpeed);
		await tween.finished;
	_boardPosition += spaces;
	
func sendToJail(jailPosition : Vector2):
	if !_inJail:
		print("Player sent to jail");
		var tween =  create_tween();
		tween.tween_property(piece, "position", jailPosition, playerMoveSpeed * 3);
		_inJail = true;
		
func escapeFromJail(boardPosition: Vector2):
	if _inJail:
		print("Player escaped from jail");
		var tween =  create_tween();
		tween.tween_property(piece, "position", boardPosition, playerMoveSpeed * 3);
		_inJail = false;

func isInJail():
	return _inJail;
