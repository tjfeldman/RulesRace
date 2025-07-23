extends Node2D

@export var boardTiles : Array[Tile];
@export var jailTile: Node;

var numberOfTiles : int;

func _ready() -> void:
	numberOfTiles = boardTiles.size();
	
func _getTile(pos: int):
	if pos >= 0 && pos < numberOfTiles:
		return boardTiles[pos];
	return null;

func getTilePosition(pos: int):
	var tile = _getTile(pos);
	return tile.global_position if tile != null else null;
	
func getJailPosition():
	return jailTile.global_position;
	
func getPlayerPosition(player: Node2D):
	return getTilePosition(player.getBoardPosition());
	
func isOfficeSpace(pos: int):
	var tile = _getTile(pos);
	return tile != null && tile.isOfficeSpace();

##TODO: DELETE IN FUTURE
#func calculateMove(startPosition : int, spaces: int):
	#var step = 1 if (spaces < 0) else -1; #negative step for forward, positive step for backwards
	#var positions : Array[Tile];
	##since range() is exclusive, we start from the tile we will end on and build backwards
	#for i : int in range(startPosition + spaces, startPosition, step):
		##make sure player doesn't move before the start or past the goal
		#if i >= 0 && i < numberOfTiles:
			#positions.push_front(boardTiles[i]);
	#return positions;
