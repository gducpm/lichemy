extends Node

var elements: Dictionary = {}

func _ready():
	_initialize_database()

func _initialize_database():
	# Hydrogen to Calcium (1-20)
	add_element(1, "H", "Hydrogen", 1.008, 2.20, 1, "nonmetal", Color(1.0, 1.0, 1.0))
	add_element(2, "He", "Helium", 4.0026, 0.0, 2, "noble gas", Color(0.8, 0.9, 1.0))
	add_element(3, "Li", "Lithium", 6.94, 0.98, 1, "alkali metal", Color(0.8, 0.4, 0.8))
	add_element(4, "Be", "Beryllium", 9.0122, 1.57, 2, "alkaline earth metal", Color(0.7, 0.9, 0.1))
	add_element(5, "B", "Boron", 10.81, 2.04, 3, "metalloid", Color(0.9, 0.6, 0.6))
	add_element(6, "C", "Carbon", 12.011, 2.55, 4, "nonmetal", Color(0.3, 0.3, 0.3))
	add_element(7, "N", "Nitrogen", 14.007, 3.04, 5, "nonmetal", Color(0.2, 0.4, 1.0))
	add_element(8, "O", "Oxygen", 15.999, 3.44, 6, "nonmetal", Color(1.0, 0.2, 0.2))
	add_element(9, "F", "Fluorine", 18.998, 3.98, 7, "halogen", Color(0.6, 0.9, 0.3))
	add_element(10, "Ne", "Neon", 20.180, 0.0, 8, "noble gas", Color(1.0, 0.4, 0.8))
	add_element(11, "Na", "Sodium", 22.990, 0.93, 1, "alkali metal", Color(0.6, 0.4, 0.8))
	add_element(12, "Mg", "Magnesium", 24.305, 1.31, 2, "alkaline earth metal", Color(0.5, 0.9, 0.1))
	add_element(13, "Al", "Aluminum", 26.982, 1.61, 3, "post-transition metal", Color(0.7, 0.7, 0.75))
	add_element(14, "Si", "Silicon", 28.085, 1.90, 4, "metalloid", Color(0.6, 0.6, 0.7))
	add_element(15, "P", "Phosphorus", 30.974, 2.19, 5, "nonmetal", Color(1.0, 0.6, 0.2))
	add_element(16, "S", "Sulfur", 32.06, 2.58, 6, "nonmetal", Color(1.0, 1.0, 0.2))
	add_element(17, "Cl", "Chlorine", 35.45, 3.16, 7, "halogen", Color(0.4, 1.0, 0.4))
	add_element(18, "Ar", "Argon", 39.95, 0.0, 8, "noble gas", Color(0.8, 0.8, 1.0))
	add_element(19, "K", "Potassium", 39.098, 0.82, 1, "alkali metal", Color(0.6, 0.2, 0.8))
	add_element(20, "Ca", "Calcium", 40.078, 1.00, 2, "alkaline earth metal", Color(0.4, 0.9, 0.1))

func add_element(atomic_number: int, symbol: String, name: String, atomic_mass: float, electronegativity: float, valence_electrons: int, category: String, color: Color):
	var data = ElementData.new(atomic_number, symbol, name, atomic_mass, electronegativity, valence_electrons, category, color)
	elements[atomic_number] = data
	elements[symbol] = data

func get_element(identifier) -> ElementData:
	if elements.has(identifier):
		return elements[identifier]
	return null
