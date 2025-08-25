extends Node2D
class_name Gameboard

@export var boardTiles : Array[Tile];
@export var jailTile: Node;

var numberOfTiles : int;

func _ready() -> void:
	numberOfTiles = boardTiles.size() -1;
	
func _getTile(pos: int):
	if pos >= 0 && pos < numberOfTiles:
		return boardTiles[pos];
	elif pos < 0:
		return boardTiles.front();
	elif pos >= numberOfTiles:
		return boardTiles.back();

func getTilePosition(pos: int):
	var tile = _getTile(pos);
	return tile.global_position;
	
func getJailPosition():
	return jailTile.global_position;
	
func getPlayerPosition(player: Node2D):
	return getTilePosition(player.getBoardPosition());
	
func isOfficeSpace(pos: int):
	var tile = _getTile(pos);
	return tile != null && tile.isOfficeSpace();
	
func isGoalSpace(pos: int):
	return pos >= numberOfTiles;
