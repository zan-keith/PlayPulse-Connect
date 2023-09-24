extends Control


var prev_val=Vector3.ZERO
export var step=0.2
var  u=Vector3.ZERO
var velocityU=Vector3.ZERO
signal gyro_input



func _process(delta):
	
	var v=Input.get_accelerometer().normalized()
	
	var velocityV=v-u/delta
	
	
	var acceleration=velocityV-velocityU
	
	


	velocityU=velocityV
	

	u=v
