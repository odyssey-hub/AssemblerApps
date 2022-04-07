null macro param1
	xor param1,param1
endm

ifnull macro param1,param2
	test param1,param1
	jz param2
endm