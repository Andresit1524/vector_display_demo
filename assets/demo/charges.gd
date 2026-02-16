extends Node

## Muestra u oculta los valores de las cargas
func toggle_show_charges_values(activate: bool) -> void:
	for charge in get_children():
		charge.show_value = activate

## Muestra u oculta las fuerzas de las cargas
func toggle_show_forces(activate: bool) -> void:
	for charge in get_children():
		charge.show_force = activate

## Muestra u oculta los componentes de las fuerzas de las cargas
func toggle_show_charges_axes(activate: bool) -> void:
	for charge in get_children():
		charge.show_axes = activate
