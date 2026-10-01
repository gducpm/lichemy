class_name Atom
extends RigidBody2D

var element_data: ElementData
var current_bonds: int = 0
var max_bonds: int = 0

var dragging: bool = false
var drag_offset: Vector2 = Vector2.ZERO

@onready var collision_shape = $CollisionShape2D
@onready var label = $Label

signal atom_clicked(atom: Atom)

func setup(p_element_data: ElementData):
	element_data = p_element_data
	
	if element_data.valence_electrons <= 4:
		max_bonds = element_data.valence_electrons
	else:
		max_bonds = 8 - element_data.valence_electrons
		
	if element_data.valence_electrons == 8 or (element_data.atomic_number == 2):
		max_bonds = 0

func _ready():
	input_pickable = true
	if element_data:
		label.text = element_data.symbol
		var radius = 20.0 + (element_data.atomic_mass / 5.0)
		radius = clamp(radius, 15.0, 45.0)
		var circle = CircleShape2D.new()
		circle.radius = radius
		collision_shape.shape = circle
		mass = element_data.atomic_mass / 10.0
	
func _physics_process(delta):
	if dragging:
		global_position = get_global_mouse_position() - drag_offset

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_offset = get_global_mouse_position() - global_position
			freeze = true
			atom_clicked.emit(self)

func _input(event):
	if dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			dragging = false
			freeze = false

func _draw():
	if not element_data:
		return
	var radius = collision_shape.shape.radius if collision_shape.shape else 20.0
	draw_circle(Vector2.ZERO, radius, element_data.color)
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, Color.BLACK, 2.0, true)
	
	var angle_step = TAU / 8.0
	for i in range(element_data.valence_electrons):
		var angle = i * angle_step - PI/2
		var pos = Vector2(cos(angle), sin(angle)) * (radius - 4.0)
		draw_circle(pos, 3.0, Color.YELLOW)

func can_bond() -> bool:
	return current_bonds < max_bonds

func add_bond():
	current_bonds += 1
