extends Node2D
class_name PlayerManager

@export var board: Gameboard;

static var _players : Array[Player];
static var _winning_order: Array[Player];
static var _player_board_order: Array[Player]; #Array[int, Player]
static func getPlayers(): return _players.duplicate();
static func getPrisonPlayers(): return getPlayers().filter(func(p): if p.isInJail(): return p);
static func getWinningOrder(): return _winning_order;
static func isGameOver(): return _players.size() == 1;

func _ready() -> void:
	Events.player_moved.connect(_update_board_order);
	Events.player_reached_goal.connect(_player_reaches_goal);
	var offset = 0;
	for child in self.get_children():
		if child is Player:
			child.board = board;
			_players.append(child);
			_player_board_order.append(child);
			#set piece offset
			PersonalRuleManager.register_personal_rule(child);
			print (child.getPersonalRule());
			
			child.board_offset = offset;
			offset += 1;
	
func _player_reaches_goal(player: Player):
	_players.erase(player);
	_player_board_order.erase(player);
	_winning_order.push_back(player);
	if isGameOver():
		_winning_order.push_back(_players[0]);
		Events.emit_signal("game_over");
				
func _update_board_order():
	_player_board_order.sort_custom(func(a, b): return a.getBoardPosition() > b.getBoardPosition());
		
#returns 0 if player hasn't finished
static func getPlayerFinishedPlace(player: Player):
	return _winning_order.find(player) + 1;
	
static func getLeadingPlayer():
	if _player_board_order.size() < 2:
		return null;
	
	var first = _player_board_order[0];
	var second = _player_board_order[1];
	
	if first.getBoardPosition() != second.getBoardPosition():
		return first;
	return null;
		
static func getPlayerAhead(player: Player):
	var pos = player.getBoardPosition();
	var i = _player_board_order.find(player)
	
	while i > 0:
		#we check the next player in the board order
		i-= 1;
		var next_player = _player_board_order[i];
		if next_player.getBoardPosition() > pos:
			#if this player's position is greater, they are ahead of you
			return next_player;
			
	#no player is ahead of you
	return null;
	
#returns list of other active players
static func getListOfAllOtherPlayers(player: Player):
	return _players.filter(func(p): return p != player and not p.hasFinished());
