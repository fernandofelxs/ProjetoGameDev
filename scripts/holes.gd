extends TileMapLayer

@export var target_cell1 := Vector2i(6, -5)
@export var target_cell2 := Vector2i(7, -5)

# Atlas coords inside A5.png
@export var wood_atlas_coords := Vector2i(3, 15)

func _on_fillable_hole_area_hole_triggered() -> void:
	var cells := [target_cell1, target_cell2]

	for cell in cells:
		var data := get_cell_tile_data(cell)
		if data == null:
			continue

		var source_id := get_cell_source_id(cell)

		set_cell(
			cell,
			source_id,
			wood_atlas_coords
		)
