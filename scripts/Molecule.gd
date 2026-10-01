class_name Molecule
extends Node2D

var atoms: Array[Atom] = []
var bonds: Array[Dictionary] = [] 

func add_atom(atom: Atom):
	if not atoms.has(atom):
		atoms.append(atom)
		
func add_bond(atom1: Atom, atom2: Atom, joint: PinJoint2D):
	bonds.append({"atom1": atom1, "atom2": atom2, "joint": joint})
	atom1.add_bond()
	atom2.add_bond()
	queue_redraw()

func get_formula() -> String:
	var counts = {}
	for atom in atoms:
		var sym = atom.element_data.symbol
		if counts.has(sym):
			counts[sym] += 1
		else:
			counts[sym] = 1
	var formula = ""
	var keys = counts.keys()
	keys.sort()
	for sym in keys:
		formula += sym
		if counts[sym] > 1:
			formula += str(counts[sym])
	return formula

func remove_atom(target_atom: Atom):
	var bonds_to_remove = []
	for bond in bonds:
		if bond["atom1"] == target_atom or bond["atom2"] == target_atom:
			bonds_to_remove.append(bond)
			if is_instance_valid(bond["joint"]):
				bond["joint"].queue_free()
			if bond["atom1"] != target_atom: bond["atom1"].current_bonds -= 1
			if bond["atom2"] != target_atom: bond["atom2"].current_bonds -= 1
			
	for b in bonds_to_remove:
		bonds.erase(b)
		
	atoms.erase(target_atom)
	target_atom.queue_free()
	
	if atoms.size() == 0:
		queue_free()
	else:
		queue_redraw()

func break_apart():
	var workspace = get_tree().current_scene.get_node("Workspace")
	for bond in bonds:
		if is_instance_valid(bond["joint"]):
			bond["joint"].queue_free()
	bonds.clear()
	
	var center = Vector2.ZERO
	var valid_atoms = []
	for atom in atoms:
		if is_instance_valid(atom):
			center += atom.global_position
			valid_atoms.append(atom)
	
	if valid_atoms.size() > 0:
		center /= valid_atoms.size()
	
	for atom in valid_atoms:
		atom.current_bonds = 0
		var dir = (atom.global_position - center).normalized()
		if dir == Vector2.ZERO:
			dir = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var glob_pos = atom.global_position + dir * 80.0
		atom.reparent(workspace)
		atom.global_position = glob_pos
			
	queue_free()

func _draw():
	for bond in bonds:
		var pos1 = bond["atom1"].position
		var pos2 = bond["atom2"].position
		draw_line(pos1, pos2, Color.DARK_GRAY, 6.0, true)
		
func _process(delta):
	queue_redraw()
