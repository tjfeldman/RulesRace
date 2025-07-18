extends Sprite2D

class_name Tile

@export var color : Colors.TileColor = Colors.TileColor.NONE;
@export var officeSpace : bool = false;

func isOfficeSpace():
	return officeSpace;
