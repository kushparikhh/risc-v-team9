.text
.global main
main:
    li  a0, 0  # all lights off
    li  t1, 255 #t1 = target: all 8 lights on

lights_on:
    slli a0, a0, 1 #multiplying by 2
    addi a0, a0, 1  #adding 1
    jal  ra, delay  #producing a delay for the light pattern to hold for a while 
    bne  a0, t1, lights_on #if a0 != t1 (all 8 are not on yet) --> go through lights_on again 

lights_off:
    jal  ra, delay 
    li   a0, 0
    jal  ra, delay
    j    main 

delay:
    li   t0, 5000
delay_loop:
    addi t0, t0, -1
    bne  t0, zero, delay_loop
    ret

