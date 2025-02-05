.text
.global matmul_6x8



# void matmul_6x8(
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

matmul_6x8:

    STP     x29, x30, [sp, #-16]!   // Save frame pointer and return address
    MOV     x29, sp 


    #a_idx
    #MUL     x8, x5, x3      // x9 = i * N
    #ADD     x8, x8, x7      // x9 = i * N + k
    #ADD     x0, x0, x8 


    #b_idx 

    MOV x17, #4        
    SDIV x18,x3 ,x17 
    MOV x16, #8 
    #MUL x9, x6, x16      // x9 = j * 8
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
    ADD         x14, x13, x3 
    PRFM        PLDL1KEEP, [x14]
    ADD         x15, x14, x3 
    PRFM        PLDL1KEEP, [x15]

    #Prefetch B block
    PRFM        PLDL1KEEP, [x1, 0]
    PRFM        PLDL1KEEP, [x1, 64]
    PRFM        PLDL1KEEP, [x1, 128]
    PRFM        PLDL1KEEP, [x1, 192]

    #Load A blolck
    LDP         q0,  q6,  [x0], 32
    LDP         q1,  q7,  [x11], 32
    LDP         q2,  q8,  [x12], 32
    LDP         q3,  q9,  [x13], 32
    LDP         q4,  q10, [x14], 32
    LDP         q5,  q11, [x15], 32


    #Initilize C block
    EOR  v20.16b, v20.16b, v20.16b  // Zero out v20
    EOR  v21.16b, v21.16b, v21.16b  // Zero out v21
    EOR  v22.16b, v22.16b, v22.16b  // Zero out v22
    EOR  v23.16b, v23.16b, v23.16b  // Zero out v23
    EOR  v24.16b, v24.16b, v24.16b  // Zero out v24
    EOR  v25.16b, v25.16b, v25.16b  // Zero out v25
    EOR  v26.16b, v26.16b, v26.16b  // Zero out v26
    EOR  v27.16b, v27.16b, v27.16b  // Zero out v27
    EOR  v28.16b, v28.16b, v28.16b  // Zero out v28
    EOR  v29.16b, v29.16b, v29.16b  // Zero out v29
    EOR  v30.16b, v30.16b, v30.16b  // Zero out v30
    EOR  v31.16b, v31.16b, v31.16b  // Zero out v31



    #Load B Block aprtial (4x8)
    LDP         q12, q13, [x1], 32
    LDP         q14, q15, [x1], 32





loop_start:


    #LDR     x17, [x10]      // Load the value at address pointed to by x1 into w0
    #ADD     x17, x17, #1    // Increment the value in w0 by 1
    #STR     x17, [x10]      // Store the incremented value back to the address in x1

    FMLA        v20.4s, v12.4s,  v0.s[0]
    FMLA        v22.4s, v12.4s,  v1.s[0]
    LDP         q16,  q17, [x1], 32
    FMLA        v24.4s, v12.4s,  v2.s[0]
    FMLA        v26.4s, v12.4s,  v3.s[0]
    LDP         q18,  q19, [x1], 32
    FMLA        v28.4s, v12.4s,  v4.s[0]
    FMLA        v30.4s, v12.4s,  v5.s[0]
    FMLA        v21.4s, v13.4s,  v0.s[0]
    FMLA        v23.4s, v13.4s,  v1.s[0]
    FMLA        v25.4s, v13.4s,  v2.s[0]
    FMLA        v27.4s, v13.4s,  v3.s[0]
    FMLA        v29.4s, v13.4s,  v4.s[0]
    FMLA        v31.4s, v13.4s,  v5.s[0]


    FMLA        v20.4s, v14.4s,  v0.s[1]
    FMLA        v22.4s, v14.4s,  v1.s[1]
    FMLA        v24.4s, v14.4s,  v2.s[1]
    FMLA        v26.4s, v14.4s,  v3.s[1]
    FMLA        v28.4s, v14.4s,  v4.s[1]
    FMLA        v30.4s, v14.4s,  v5.s[1]
    FMLA        v21.4s, v15.4s,  v0.s[1]
    FMLA        v23.4s, v15.4s,  v1.s[1]
    FMLA        v25.4s, v15.4s,  v2.s[1]
    FMLA        v27.4s, v15.4s,  v3.s[1]
    FMLA        v29.4s, v15.4s,  v4.s[1]
    FMLA        v31.4s, v15.4s,  v5.s[1]

    LDP         q12,  q13, [x1], 32
    FMLA        v20.4s, v16.4s,  v0.s[2]
    FMLA        v22.4s, v16.4s,  v1.s[2]
    LDP         q14,  q15, [x1], 32
    FMLA        v24.4s, v16.4s,  v2.s[2]
    FMLA        v26.4s, v16.4s,  v3.s[2]
    PRFM       PLDL1KEEP, [x1, 128]        // Prefetch B
    FMLA        v28.4s, v16.4s,  v4.s[2]
    FMLA        v30.4s, v16.4s,  v5.s[2]
    PRFM       PLDL1KEEP, [x1, 256]
    FMLA        v21.4s, v17.4s,  v0.s[2]
    FMLA        v23.4s, v17.4s,  v1.s[2]
    FMLA        v25.4s, v17.4s,  v2.s[2]
    FMLA        v27.4s, v17.4s,  v3.s[2]
    FMLA        v29.4s, v17.4s,  v4.s[2]
    FMLA        v31.4s, v17.4s,  v5.s[2]
    PRFM        PLDL1KEEP, [x0]




    FMLA        v20.4s, v18.4s,  v0.s[3]
    FMLA        v22.4s, v18.4s,  v1.s[3]
    FMLA        v24.4s, v18.4s,  v2.s[3]
    FMLA        v26.4s, v18.4s,  v3.s[3]
    PRFM        PLDL1KEEP, [x11]
    FMLA        v28.4s, v18.4s,  v4.s[3]
    FMLA        v30.4s, v18.4s,  v5.s[3]
    FMLA        v21.4s, v19.4s,  v0.s[3]
    PRFM        PLDL1KEEP, [x12]
    FMLA        v23.4s, v19.4s,  v1.s[3]
    FMLA        v25.4s, v19.4s,  v2.s[3]
    FMLA        v27.4s, v19.4s,  v3.s[3]
    PRFM        PLDL1KEEP, [x13]
    FMLA        v29.4s, v19.4s,  v4.s[3]
    FMLA        v31.4s, v19.4s,  v5.s[3]
    PRFM        PLDL1KEEP, [x14]
    PRFM        PLDL1KEEP, [x15]

    LDP         q16,  q17, [x1], 32
    FMLA        v20.4s, v12.4s,  v6.s[0]
    FMLA        v22.4s, v12.4s,  v7.s[0]
    LDP         q18,  q19, [x1], 32
    FMLA        v24.4s, v12.4s,  v8.s[0]
    FMLA        v26.4s, v12.4s,  v9.s[0]
    FMLA        v28.4s, v12.4s, v10.s[0]
    FMLA        v30.4s, v12.4s, v11.s[0]
    FMLA        v21.4s, v13.4s,  v6.s[0]
    FMLA        v23.4s, v13.4s,  v7.s[0]
    FMLA        v25.4s, v13.4s,  v8.s[0]
    FMLA        v27.4s, v13.4s,  v9.s[0]
    FMLA        v29.4s, v13.4s, v10.s[0]
    FMLA        v31.4s, v13.4s, v11.s[0]

    FMLA        v20.4s, v14.4s,  v6.s[1]
    FMLA        v22.4s, v14.4s,  v7.s[1]
    FMLA        v24.4s, v14.4s,  v8.s[1]
    FMLA        v26.4s, v14.4s,  v9.s[1]
    FMLA        v28.4s, v14.4s, v10.s[1]
    FMLA        v30.4s, v14.4s, v11.s[1]
    FMLA        v21.4s, v15.4s,  v6.s[1]
    FMLA        v23.4s, v15.4s,  v7.s[1]
    FMLA        v25.4s, v15.4s,  v8.s[1]
    FMLA        v27.4s, v15.4s,  v9.s[1]
    FMLA        v29.4s, v15.4s, v10.s[1]
    FMLA        v31.4s, v15.4s, v11.s[1]

    LDP         q12,  q13, [x1], 32
    FMLA        v20.4s, v16.4s,  v6.s[2]
    FMLA        v20.4s, v18.4s,  v6.s[3]
    LDP         q14,  q15, [x1], 32
    FMLA        v21.4s, v17.4s,  v6.s[2]
    FMLA        v21.4s, v19.4s,  v6.s[3]
    LDP         q0,  q6, [x0], 32
    FMLA        v22.4s, v16.4s,  v7.s[2]
    FMLA        v22.4s, v18.4s,  v7.s[3]
    FMLA        v23.4s, v17.4s,  v7.s[2]
    FMLA        v23.4s, v19.4s,  v7.s[3]
    LDP         q1,  q7, [x11], 32
    FMLA        v24.4s, v16.4s,  v8.s[2]
    FMLA        v24.4s, v18.4s,  v8.s[3]
    FMLA        v25.4s, v17.4s,  v8.s[2]
    FMLA        v25.4s, v19.4s,  v8.s[3]
    LDP         q2,  q8, [x12], 32
    FMLA        v26.4s, v16.4s,  v9.s[2]
    FMLA        v26.4s, v18.4s,  v9.s[3]
    FMLA        v27.4s, v17.4s,  v9.s[2]
    FMLA        v27.4s, v19.4s,  v9.s[3]
    LDP         q3,  q9, [x13], 32

    FMLA        v28.4s, v16.4s, v10.s[2]
    FMLA        v28.4s, v18.4s, v10.s[3]
    FMLA        v29.4s, v17.4s, v10.s[2]
    FMLA        v29.4s, v19.4s, v10.s[3]
    LDP         q4,  q10, [x14], 32

    FMLA        v30.4s, v16.4s, v11.s[2]
    FMLA        v30.4s, v18.4s, v11.s[3]
    FMLA        v31.4s, v17.4s, v11.s[2]
    FMLA        v31.4s, v19.4s, v11.s[3]
    LDP         q5,  q6, [x15], 32

    #ADD         x10, x10, x16
    ADD         x7, x7, x16
    CMP         x7, x18
    BGE         loop_end
    B           loop_start



loop_end:

    #Store C in memory
    STP         q20, q21,  [x2]
    ADD         x2, x2, x4
    STP         q22, q23, [x2]
    ADD         x2, x2, x4
    STP         q24, q25, [x2]
    ADD         x2, x2, x4
    STP         q26, q27, [x2]
    ADD         x2, x2, x4

    STP         q28, q29, [x2]
    ADD         x2, x2, x4

    STP         q30, q31,  [x2]

    LDP         x29, x30, [sp], #16


   # MOV         x0,x2
    RET

# Data section for the "verified" message
.section .rodata
msg:
    .asciz "verified\n"
