extends Node2D

@onready var workspace = $Workspace
@onready var ui_panel = $UI/Panel/VBoxContainer
@onready var element_dropdown = $UI/Panel/VBoxContainer/ElementDropdown
@onready var spawn_button = $UI/Panel/VBoxContainer/SpawnButton
@onready var info_label = $UI/Panel/InfoLabel
@onready var action_container = $UI/Panel/ActionContainer
@onready var unlink_button = $UI/Panel/ActionContainer/UnlinkButton
@onready var clone_button = $UI/Panel/ActionContainer/CloneButton
@onready var delete_button = $UI/Panel/ActionContainer/DeleteButton

var atom_scene = preload("res://scenes/Atom.tscn")
var selected_element_symbol = "H"
var selected_atom: Atom = null

func _ready():
	_populate_dropdown()
	spawn_button.pressed.connect(_on_spawn_button_pressed)
	unlink_button.pressed.connect(_on_unlink_pressed)
	clone_button.pressed.connect(_on_clone_pressed)
	delete_button.pressed.connect(_on_delete_pressed)
	_create_boundaries()

var walls_body: StaticBody2D

func _create_boundaries():
	walls_body = StaticBody2D.new()
	add_child(walls_body)
	get_tree().root.size_changed.connect(_update_boundaries)
	_update_boundaries()

func _update_boundaries():
	for child in walls_body.get_children():
		child.queue_free()
		
	var vp_size = get_viewport_rect().size
	var w = vp_size.x
	var h = vp_size.y
	var thickness = 200.0
	
	var rects = [
		{"pos": Vector2(w / 2.0, -thickness / 2.0), "size": Vector2(w, thickness)},
		{"pos": Vector2(w / 2.0, h + thickness / 2.0), "size": Vector2(w, thickness)},
		{"pos": Vector2(250 - thickness / 2.0, h / 2.0), "size": Vector2(thickness, h)},
		{"pos": Vector2(w + thickness / 2.0, h / 2.0), "size": Vector2(thickness, h)}
	]
	
	for rect_data in rects:
		var shape = CollisionShape2D.new()
		var rect = RectangleShape2D.new()
		rect.size = rect_data["size"]
		shape.shape = rect
		shape.position = rect_data["pos"]
		walls_body.add_child(shape)

func _populate_dropdown():
	element_dropdown.clear()
	var symbols = ["H", "He", "Li", "Be", "B", "C", "N", "O", "F", "Ne", "Na", "Mg", "Al", "Si", "P", "S", "Cl", "Ar", "K", "Ca"]
	for sym in symbols:
		element_dropdown.add_item(sym)
	element_dropdown.item_selected.connect(_on_element_selected)

func _on_element_selected(index):
	selected_element_symbol = element_dropdown.get_item_text(index)

func _on_spawn_button_pressed():
	spawn_atom(selected_element_symbol, get_viewport_rect().size / 2.0)

func spawn_atom(symbol: String, pos: Vector2):
	var element_data = ElementDatabase.get_element(symbol)
	if element_data:
		var atom = atom_scene.instantiate() as Atom
		atom.setup(element_data)
		workspace.add_child(atom)
		atom.global_position = pos + Vector2(randf_range(-20, 20), randf_range(-20, 20))
		atom.atom_clicked.connect(_on_atom_clicked)
		ReactionManager.register_atom(atom)

func _on_atom_clicked(atom: Atom):
	selected_atom = atom
	info_label.text = "Selected: %s (%s)\nMass: %.3f\nValence e-: %d\nBonds: %d/%d" % [
		atom.element_data.name,
		atom.element_data.symbol,
		atom.element_data.atomic_mass,
		atom.element_data.valence_electrons,
		atom.current_bonds,
		atom.max_bonds
	]
	
	var is_mol = atom.get_parent() is Molecule
	unlink_button.disabled = not is_mol
	clone_button.disabled = not is_mol
	delete_button.disabled = false
	
	if is_mol:
		info_label.text += "\n\nMolecule Formula: " + atom.get_parent().get_formula()

func _on_delete_pressed():
	if selected_atom and is_instance_valid(selected_atom):
		ReactionManager.unregister_atom(selected_atom)
		if selected_atom.get_parent() is Molecule:
			selected_atom.get_parent().remove_atom(selected_atom)
		else:
			selected_atom.queue_free()
		
		selected_atom = null
		info_label.text = "Select an atom to view info."
		unlink_button.disabled = true
		clone_button.disabled = true
		delete_button.disabled = true

func _on_unlink_pressed():
	if selected_atom and is_instance_valid(selected_atom) and selected_atom.get_parent() is Molecule:
		selected_atom.get_parent().break_apart()
		unlink_button.disabled = true
		clone_button.disabled = true
		_on_atom_clicked(selected_atom)

func _on_clone_pressed():
	if selected_atom and is_instance_valid(selected_atom) and selected_atom.get_parent() is Molecule:
		clone_molecule(selected_atom.get_parent())

func clone_molecule(original_mol: Molecule):
	var sign_x = 1 if randf() > 0.5 else -1
	var sign_y = 1 if randf() > 0.5 else -1
	var offset = Vector2(randf_range(200, 350) * sign_x, randf_range(200, 350) * sign_y)
	var atom_map = {}
	
	var new_mol = load("res://scenes/Molecule.tscn").instantiate()
	workspace.add_child(new_mol)
	ReactionManager.molecule_formed.emit(new_mol)
	
	for old_a in original_mol.atoms:
		var new_a = atom_scene.instantiate() as Atom
		new_a.setup(old_a.element_data)
		new_mol.add_child(new_a)
		new_a.global_position = old_a.global_position + offset
		new_mol.add_atom(new_a)
		new_a.atom_clicked.connect(_on_atom_clicked)
		ReactionManager.register_atom(new_a)
		atom_map[old_a] = new_a
		
	for old_bond in original_mol.bonds:
		var new_a1 = atom_map[old_bond["atom1"]]
		var new_a2 = atom_map[old_bond["atom2"]]
		
		var joint = PinJoint2D.new()
		new_mol.add_child(joint)
		joint.global_position = (new_a1.global_position + new_a2.global_position) / 2.0
		joint.node_a = joint.get_path_to(new_a1)
		joint.node_b = joint.get_path_to(new_a2)
		joint.disable_collision = true
		
		new_mol.add_bond(new_a1, new_a2, joint)
