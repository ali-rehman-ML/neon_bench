.text
.global matmul_4x4



# void matmul_4x4(
#     float* A,                x0
#     float* B,                x1
#     float* C + c_index,                x2
#     size_t N,          x3
#     size_t K,           x4
#     size_t i,                 x5
#     size_t j,         x6
#     size_t k,         x7
#     size_t a_idx      x8
#     size_t b_idx      x9
#     size_t loop_count x10) 

matmul_4x4:

    STP     x29, x30, [sp, #-16]!   // Save frame pointer and return address
    MOV     x29, sp 


    #a_idx
    #MUL     x8, x5, x3      // x9 = i * N
    #ADD     x8, x8, x7      // x9 = i * N + k
    #ADD     x0, x0, x8 


    #b_idx 

    MOV x17, #4        
    SDIV x18,x3 ,x17

    #MUL x9, x6, x17      // x9 = j * 8
    #ADD x9, x9, x7        // x9 = j * 8 + k
    #ADD x1, x1, x9        // B = B + b_idx


    #Prefetch A block

    PRFM        PLDL1KEEP, [x0]
    ADD         x11, x0, x3 
    PRFM        PLDL1KEEP, [x11]
    ADD         x12, x11, x3 
    PRFM        PLDL1KEEP, [x12]
    ADD         x13, x12, x3 
    PRFM        PLDL1KEEP, [x13]


    #Prefetch B block



    PRFM        PLDL1KEEP, [x1, 0]


    #Load A blolck
    LDR         q0, [x0], #16
    LDR         q1, [x0], #16
    LDR         q2, [x0], #16
    LDR         q3, [x0], #16




    #Initilize C block
    MOVI    v20.4s, #0
    MOVI    v21.4s, #0
    MOVI    v22.4s, #0
    MOVI    v23.4s, #0






    #Load B Block aprtial (2x8)
    LDR         q4, [x1], #16
    LDR         q5, [x1], #16





loop_start:

    PRFM        PLDL1KEEP, [x1,0]
    LDR         q6, [x1], #16  

    FMLA        v20.4s, v4.4s,  v0.s[0]
    FMLA        v21.4s, v4.4s,  v1.s[0]
    FMLA        v22.4s, v4.4s,  v2.s[0]
    FMLA        v23.4s, v4.4s,  v3.s[0]
    


    LDR         q7, [x1], #16


    FMLA        v20.4s, v5.4s,  v0.s[1]
    FMLA        v21.4s, v5.4s,  v1.s[1]
    FMLA        v22.4s, v5.4s,  v2.s[1]
    FMLA        v23.4s, v5.4s,  v3.s[1]
    LDR         q4, [x1], #16


    


    FMLA        v20.4s, v6.4s,  v0.s[2]
    FMLA        v20.4s, v7.4s,  v0.s[3]
    LDR         q0, [x0], #16

    FMLA        v21.4s, v6.4s,  v1.s[2]
    FMLA        v21.4s, v7.4s,  v1.s[3]
    LDR         q1, [x0], #16


    FMLA        v22.4s, v6.4s,  v2.s[2]
    FMLA        v22.4s, v7.4s,  v2.s[3]
    LDR         q2, [x0], #16
    FMLA        v23.4s, v6.4s,  v3.s[2]
    FMLA        v23.4s, v7.4s,  v3.s[3]
    
    LDR         q3, [x0], #16
    LDR         q5, [x1], #16



    ADD         x7, x7, x17
    CMP         x7, x18
    BGE         loop_end
    B           loop_start



loop_end:

    #Store C in memory
    STR         q20,  [x2]
    ADD         x2, x2, x4
    STR         q21, [x2]
    ADD         x2, x2, x4
    STR         q22, [x2]
    ADD         x2, x2, x4
    STR         q23, [x2]
    

    LDP         x29, x30, [sp], #16


    RET

# Data section for the "verified" message
.section .rodata
msg:
    .asciz "verified\n"
