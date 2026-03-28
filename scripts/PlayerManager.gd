extends Node2D
class_name PlayerManager

@export var board: Gameboard;

static var _players : Array[Player];
static var _leading_player: Player = null; 
static var _leading_pos: int = 0;
static func getPlayers(): return _players.duplicate();
static func getPrisonPlayers(): return getPlayers().filter(func(p): if p.isInJail(): return p);
static func getLeadingPlayer(): return _leading_player;

func _ready() -> void:
	Events.player_moved.connect(_update_leading_player);
	for child in self.get_children():
		if child is Player:
			child.board = board;
			_players.append(child);
			
func _update_leading_player(player: Player):
	#The leading player is the single player who is furthest away on the board
	var pos = player.getBoardPosition();
	if pos > _leading_pos:
		_leading_pos = pos;
		_leading_player = player;
	elif pos == _leading_pos:
		#players do not share leads
		_leading_player = null;

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
