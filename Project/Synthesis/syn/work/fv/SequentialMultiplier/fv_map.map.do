
//input ports
add mapped point clock clock -type PI PI
add mapped point reset reset -type PI PI
add mapped point multiplicand[3] multiplicand[3] -type PI PI
add mapped point multiplicand[2] multiplicand[2] -type PI PI
add mapped point multiplicand[1] multiplicand[1] -type PI PI
add mapped point multiplicand[0] multiplicand[0] -type PI PI
add mapped point multiplier[3] multiplier[3] -type PI PI
add mapped point multiplier[2] multiplier[2] -type PI PI
add mapped point multiplier[1] multiplier[1] -type PI PI
add mapped point multiplier[0] multiplier[0] -type PI PI
add mapped point start start -type PI PI

//output ports
add mapped point product[7] product[7] -type PO PO
add mapped point product[6] product[6] -type PO PO
add mapped point product[5] product[5] -type PO PO
add mapped point product[4] product[4] -type PO PO
add mapped point product[3] product[3] -type PO PO
add mapped point product[2] product[2] -type PO PO
add mapped point product[1] product[1] -type PO PO
add mapped point product[0] product[0] -type PO PO
add mapped point ready ready -type PO PO

//inout ports




//Sequential Pins
add mapped point F/State[1]/q F/State_reg_1_/Q -type DFF DFF
add mapped point F/State[2]/q F/State_reg_2_/Q -type DFF DFF
add mapped point F/State[0]/q F/State_reg_0_/Q -type DFF DFF
add mapped point A[2]/q A_reg_2_/Q -type DFF DFF
add mapped point A[3]/q A_reg_3_/Q -type DFF DFF
add mapped point A[1]/q A_reg_1_/Q -type DFF DFF
add mapped point Counter[3]/q Counter_reg_3_/Q -type DFF DFF
add mapped point A[0]/q A_reg_0_/Q -type DFF DFF
add mapped point Counter[2]/q Counter_reg_2_/Q -type DFF DFF
add mapped point Q[3]/q Q_reg_3_/Q -type DFF DFF
add mapped point Counter[1]/q Counter_reg_1_/Q -type DFF DFF
add mapped point Q[2]/q Q_reg_2_/Q -type DFF DFF
add mapped point Counter[0]/q Counter_reg_0_/Q -type DFF DFF
add mapped point Q[1]/q Q_reg_1_/Q -type DFF DFF
add mapped point Q[0]/q Q_reg_0_/Q -type DFF DFF
add mapped point M[0]/q M_reg_0_/Q -type DFF DFF
add mapped point M[1]/q M_reg_1_/Q -type DFF DFF
add mapped point M[2]/q M_reg_2_/Q -type DFF DFF
add mapped point M[3]/q M_reg_3_/Q -type DFF DFF



//Black Boxes



//Empty Modules as Blackboxes
