extends Node2D
class_name PlayerManager

@export var board: Gameboard;

static var _players : Array[Player];
static func getPlayers(): return _players.duplicate();

static var _currentTurnPlayer : int = 0;
static func getCurrentTurnPlayer(): return _players[_currentTurnPlayer];

func _ready() -> void:
	for child in self.get_children():
		if child is Player:
			child.board = board;
			_players.append(child);
	
static func nextTurn():
	_currentTurnPlayer += 1;
	if _currentTurnPlayer >= _players.size():
		_currentTurnPlayer -= _players.size();
	Events.emit_signal("start_turn");
	
#TODO: Add function to track leading player

static func getPlayerAhead(player: Player):
	#This isn't optimized, but max player size will be 12 so the affect is negligible
	var otherPlayers = getListOfAllOtherPlayers(player);
	var pos = player.getBoardPosition();
	
	var closestDist = INF;
	var closestPlayer = null;
	for p in otherPlayers:
		var dist = p.getBoardPosition() - pos;
		if (dist > 0 and dist < closestDist):
			closestDist = dist;
			closestPlayer = p;
	
	return closestPlayer;
	
#returns list of other active players
static func getListOfAllOtherPlayers(player: Player):
	return _players.filter(func(p): return p != player and not p.hasFinished());
