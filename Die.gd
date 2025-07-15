extends Node2D

@onready var dieOutput: Label = $DieResult;

enum Values {ESCAPE, ONE, TWO, THREE, JAIL=-1};
var sides : Array[Values] = [Values.ONE, Values.TWO, Values.TWO, Values.THREE, Values.JAIL, Values.ESCAPE];

func rollDie():
	var rolled = sides.pick_random();
	#animate die rolling and show rolled side
	dieOutput.text = "Die Rolled: %s" % Values.find_key(rolled);
	return rolled;
