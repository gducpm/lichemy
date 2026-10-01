extends Node

var active_atoms: Array[Atom] = []
var bond_distance_threshold: float = 60.0

signal molecule_formed(molecule)

func register_atom(atom: Atom):
	if not active_atoms.has(atom):
		active_atoms.append(atom)

func unregister_atom(atom: Atom):
	active_atoms.erase(atom)

func _physics_process(delta):
	_check_for_bonds()

func _check_for_bonds():
	for i in range(active_atoms.size()):
		for j in range(i + 1, active_atoms.size()):
			var atom1 = active_atoms[i]
			var atom2 = active_atoms[j]
			
			if not is_instance_valid(atom1) or not is_instance_valid(atom2):
				continue
				
			if atom1.can_bond() and atom2.can_bond():
				var dist = atom1.global_position.distance_to(atom2.global_position)
				if dist < bond_distance_threshold:
					# Use call_deferred to avoid state manipulation within physics tick
					call_deferred("_create_bond", atom1, atom2)

func _create_bond(atom1: Atom, atom2: Atom):
	if not is_instance_valid(atom1) or not is_instance_valid(atom2): return
	if not atom1.can_bond() or not atom2.can_bond(): return
	var dist = atom1.global_position.distance_to(atom2.global_position)
	if dist > bond_distance_threshold * 1.5: return
	
	var parent1 = atom1.get_parent()
	var parent2 = atom2.get_parent()
	var mol: Molecule = null
	
	if parent1 is Molecule and parent1 == parent2:
		return
		
	var simulation = get_tree().current_scene
	
	if parent1 is Molecule:
		mol = parent1
		_move_atom_to_molecule(atom2, mol)
	elif parent2 is Molecule:
		mol = parent2
		_move_atom_to_molecule(atom1, mol)
	else:
		var mol_scene = load("res://scenes/Molecule.tscn")
		mol = mol_scene.instantiate()
		simulation.get_node("Workspace").add_child(mol)
		_move_atom_to_molecule(atom1, mol)
		_move_atom_to_molecule(atom2, mol)
		molecule_formed.emit(mol)
		
	var joint = PinJoint2D.new()
	mol.add_child(joint)
	joint.global_position = (atom1.global_position + atom2.global_position) / 2.0
	
	joint.node_a = joint.get_path_to(atom1)
	joint.node_b = joint.get_path_to(atom2)
	joint.disable_collision = true
	
	mol.add_bond(atom1, atom2, joint)

func _move_atom_to_molecule(atom: Atom, molecule: Molecule):
	if atom.get_parent() != molecule:
		atom.reparent(molecule)
		molecule.add_atom(atom)
