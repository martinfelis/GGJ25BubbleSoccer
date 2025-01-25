class_name SpringDamper
extends Object

# Based on: allenchou.net/2015/04/game-math-precise-control-over-numeric-springing/

var omega
var zeta

var v:Variant = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(v0:Variant, osc_freq:float = 4, osc_red:float = 0.003, osc_red_h:float = 0.003):
	assert (osc_red > 0.001 and osc_red < 0.999)
	omega = osc_freq * 2 * PI
	zeta = log(1.0 - osc_red) / (-omega * osc_red_h)
	v = v0
	
func calc(x, xt, h:float):
	var f = 1.0 + 2.0 * h * zeta * omega
	var oo = omega * omega
	var hoo = oo * h
	var hhoo = hoo * h
	var det_inv = 1.0 / (f + hhoo)
	var det_x = f * x + h * v + hhoo * xt
	var det_v = v + hoo * (xt - x)
	x = det_x * det_inv
	v = det_v * det_inv
	return x

func calc_clamped_speed(x, xt, h:float, s_max:float):
	var x_old = x
	
	var x_new = calc(x, xt, h)
	var vel_new = (x_new - x_old) / h
	var speed_new = abs(vel_new)
	if not vel_new is float:
		speed_new = vel_new.length()
		
	if speed_new > s_max:
		vel_new = (vel_new / speed_new) * s_max
		x = x_old + vel_new * h
	
	return x
