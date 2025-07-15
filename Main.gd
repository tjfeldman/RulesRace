extends Node2D

@onready var player : Node2D = $PlayerToken;
@onready var board : Node2D = $Board;
@onready var die : Node2D = $Die;

func _unhandled_input(event: InputEvent) -> void:
	if (Input.is_action_just_pressed("ui_click")):
		performDieRoll();
		

func performDieRoll():
	var rolled = die.rollDie();
	#var playerPosition = player.getBoardPosition();
	#var playerInJail = player.isInJail();
	
	match rolled:
		die.Values.JAIL:
			player.sendToJail(board.jailTile.global_position);
		die.Values.ESCAPE:
			player.escapeFromJail(board.getTile(player.getBoardPosition()).global_position);
		_:
			movePlayer(rolled);

func movePlayer(spaces: int):
	#check that player is not in jail
	if !player.isInJail():
		print("Moving Player %s Spaces" %spaces);
		var moves = board.calculateMove(player.getBoardPosition(), spaces);
		player.movePlayer(spaces, moves);
	else:
		print("Cannot move player %s Spaces, they are in Jail" %spaces);
