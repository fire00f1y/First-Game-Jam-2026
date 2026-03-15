extends PointLight2D

@export var flicker_amount: float = 0.15  # how much it varies
@export var speed: float = 1.0

@onready var base_energy: float = energy

var time_offset: float

func _ready() -> void:
	# each torch gets a random starting phase so they're never in sync
	time_offset = randf() * 100.0

func _process(delta: float) -> void:
	var t : float = (Time.get_ticks_msec() / 1000.0 + time_offset) * speed
	
	# three overlapping sine waves at irrational frequency ratios
	# irrational ratios mean they never perfectly repeat
	var flicker : float = sin(t * 1.0) * 0.5
	flicker += sin(t * 2.7) * 0.25
	flicker += sin(t * 5.31) * 0.15
	flicker += sin(t * 11.13) * 0.10
	
	# small random jolt occasionally simulates a draft
	if randf() < 0.008:  # ~0.8% chance per frame
		flicker += randf_range(-0.4, 0.2)
	
	energy = base_energy + flicker * flicker_amount