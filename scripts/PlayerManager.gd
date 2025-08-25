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
#TODO: Add function to locate player ahead
#TODO: Add function to grab all other players
