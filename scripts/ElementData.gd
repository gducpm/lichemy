class_name ElementData
extends Resource

@export var atomic_number: int
@export var symbol: String
@export var name: String
@export var atomic_mass: float
@export var electronegativity: float
@export var valence_electrons: int
@export var category: String
@export var color: Color

func _init(p_atomic_number := 1, p_symbol := "H", p_name := "Hydrogen", p_atomic_mass := 1.008, p_electronegativity := 2.20, p_valence_electrons := 1, p_category := "nonmetal", p_color := Color.WHITE):
	atomic_number = p_atomic_number
	symbol = p_symbol
	name = p_name
	atomic_mass = p_atomic_mass
	electronegativity = p_electronegativity
	valence_electrons = p_valence_electrons
	category = p_category
	color = p_color
