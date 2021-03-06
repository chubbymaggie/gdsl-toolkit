type sem_id =
   Sem_PC
 | Sem_SREG
 | Sem_LLBIT
 | Sem_DEBUG
 | Sem_CONFIG1
 | Sem_CONFIG3
 | Sem_ISA_MODE
 | Sem_SRSCTL
 | Sem_EPC
 | Sem_ERROR_EPC
 | Sem_DEPC

type sem_id =
   Sem_ZERO
 | Sem_AT
 | Sem_V0
 | Sem_V1
 | Sem_A0
 | Sem_A1
 | Sem_A2
 | Sem_A3
 | Sem_T0
 | Sem_T1
 | Sem_T2
 | Sem_T3
 | Sem_T4
 | Sem_T5
 | Sem_T6
 | Sem_T7
 | Sem_S0
 | Sem_S1
 | Sem_S2
 | Sem_S3
 | Sem_S4
 | Sem_S5
 | Sem_S6
 | Sem_S7
 | Sem_T8
 | Sem_T9
 | Sem_K0
 | Sem_K1
 | Sem_GP
 | Sem_SP
 | Sem_S8
 | Sem_RA
 | Sem_HI
 | Sem_LO

type sem_id = 
   Sem_F0
 | Sem_F1
 | Sem_F2
 | Sem_F3
 | Sem_F4
 | Sem_F5
 | Sem_F6
 | Sem_F7
 | Sem_F8
 | Sem_F9
 | Sem_F10
 | Sem_F11
 | Sem_F12
 | Sem_F13
 | Sem_F14
 | Sem_F15
 | Sem_F16
 | Sem_F17
 | Sem_F18
 | Sem_F19
 | Sem_F20
 | Sem_F21
 | Sem_F22
 | Sem_F23
 | Sem_F24
 | Sem_F25
 | Sem_F26
 | Sem_F27
 | Sem_F28
 | Sem_F29
 | Sem_F30
 | Sem_F31
 | Sem_FIR
 | Sem_FCCR
 | Sem_FEXR
 | Sem_FENR
 | Sem_FCSR

type sem_id =
   Sem_CPUNUM
 | Sem_SYNCI_STEP
 | Sem_CC
 | Sem_CCRES
 | Sem_ULR

type sem_id =
   Sem_C2CCREG

val fIE = sem-reg-offset (semantic-reg-of Sem_SREG) 0
val fRE = sem-reg-offset (semantic-reg-of Sem_SREG) 25
val fCA = sem-reg-offset (semantic-reg-of Sem_CONFIG1) 2
val fISA = sem-reg-offset (semantic-reg-of Sem_CONFIG3) 14
val fDM = sem-reg-offset (semantic-reg-of Sem_DEBUG) 0
val fIEXI = sem-reg-offset (semantic-reg-of Sem_DEBUG) 1
val fEXL = sem-reg-offset (semantic-reg-of Sem_SREG) 1
val fERL = sem-reg-offset (semantic-reg-of Sem_SREG) 2
val fKSU = sem-reg-offset (semantic-reg-of Sem_SREG) 3
val fBEV = sem-reg-offset (semantic-reg-of Sem_SREG) 22
val fCSS = sem-reg-offset (semantic-reg-of Sem_SRSCTL) 0
val fPSS = sem-reg-offset (semantic-reg-of Sem_SRSCTL) 6
val fESS = sem-reg-offset (semantic-reg-of Sem_SRSCTL) 12
val fHSS = sem-reg-offset (semantic-reg-of Sem_SRSCTL) 26

val sem-reg-offset r o = @{offset=r.offset + o}r

val semantic-reg-of x = 
   case x of
      Sem_PC		: {id=Sem_PC,offset=0,size=32}
    | Sem_HI		: {id=Sem_HI,offset=0,size=32}
    | Sem_LO		: {id=Sem_LO,offset=0,size=32}
    | Sem_SREG		: {id=Sem_SREG,offset=0,size=32}
    | Sem_LLBIT 	: {id=Sem_LLBIT,offset=0,size=1}
    | Sem_DEBUG		: {id=Sem_DEBUG,offset=0,size=32}
    | Sem_CONFIG1	: {id=Sem_CONFIG1,offset=0,size=32}
    | Sem_CONFIG3	: {id=Sem_CONFIG3,offset=0,size=32}
    | Sem_ISA_MODE	: {id=Sem_ISA_MODE,offset=0,size=1}
    | Sem_SRSCTL	: {id=Sem_SRSCTL,offset=0,size=32}
    | Sem_EPC		: {id=Sem_EPC,offset=0,size=32}
    | Sem_ERROR_EPC	: {id=Sem_ERROR_EPC,offset=0,size=32}
    | Sem_DEPC		: {id=Sem_DEPC,offset=0,size=32}
    | Sem_CPUNUM	: {id=Sem_CPUNUM,offset=0,size=32}
    | Sem_SYNCI_STEP	: {id=Sem_SYNCI_STEP,offset=0,size=32}
    | Sem_CC		: {id=Sem_CC,offset=0,size=32}
    | Sem_CCRES		: {id=Sem_CCRES,offset=0,size=32}
    | Sem_ULR		: {id=Sem_ULR,offset=0,size=32}
    | Sem_C2CCREG	: {id=Sem_C2CCREG,offset=0,size=32}
   end

val semantic-gpr-of r =
   case r of
      ZERO : {id=Sem_ZERO,offset=0,size=32}
    | AT   : {id=Sem_AT  ,offset=0,size=32}
    | V0   : {id=Sem_V0  ,offset=0,size=32}
    | V1   : {id=Sem_V1  ,offset=0,size=32}
    | A0   : {id=Sem_A0  ,offset=0,size=32}
    | A1   : {id=Sem_A1  ,offset=0,size=32}
    | A2   : {id=Sem_A2  ,offset=0,size=32}
    | A3   : {id=Sem_A3  ,offset=0,size=32}
    | T0   : {id=Sem_T0  ,offset=0,size=32}
    | T1   : {id=Sem_T1  ,offset=0,size=32}
    | T2   : {id=Sem_T2  ,offset=0,size=32}
    | T3   : {id=Sem_T3  ,offset=0,size=32}
    | T4   : {id=Sem_T4  ,offset=0,size=32}
    | T5   : {id=Sem_T5  ,offset=0,size=32}
    | T6   : {id=Sem_T6  ,offset=0,size=32}
    | T7   : {id=Sem_T7  ,offset=0,size=32}
    | S0   : {id=Sem_S0  ,offset=0,size=32}
    | S1   : {id=Sem_S1  ,offset=0,size=32}
    | S2   : {id=Sem_S2  ,offset=0,size=32}
    | S3   : {id=Sem_S3  ,offset=0,size=32}
    | S4   : {id=Sem_S4  ,offset=0,size=32}
    | S5   : {id=Sem_S5  ,offset=0,size=32}
    | S6   : {id=Sem_S6  ,offset=0,size=32}
    | S7   : {id=Sem_S7  ,offset=0,size=32}
    | T8   : {id=Sem_T8  ,offset=0,size=32}
    | T9   : {id=Sem_T9  ,offset=0,size=32}
    | K0   : {id=Sem_K0  ,offset=0,size=32}
    | K1   : {id=Sem_K1  ,offset=0,size=32}
    | GP   : {id=Sem_GP  ,offset=0,size=32}
    | SP   : {id=Sem_SP  ,offset=0,size=32}
    | S8   : {id=Sem_S8  ,offset=0,size=32}
    | RA   : {id=Sem_RA  ,offset=0,size=32}
   end

val semantic-fpr-of f =
   case f of
      F0   : {id=Sem_F0  ,offset=0,size=32}
    | F1   : {id=Sem_F1  ,offset=0,size=32}
    | F2   : {id=Sem_F2  ,offset=0,size=32}
    | F3   : {id=Sem_F3  ,offset=0,size=32}
    | F4   : {id=Sem_F4  ,offset=0,size=32}
    | F5   : {id=Sem_F5  ,offset=0,size=32}
    | F6   : {id=Sem_F6  ,offset=0,size=32}
    | F7   : {id=Sem_F7  ,offset=0,size=32}
    | F8   : {id=Sem_F8  ,offset=0,size=32}
    | F9   : {id=Sem_F9  ,offset=0,size=32}
    | F10  : {id=Sem_F10 ,offset=0,size=32}
    | F11  : {id=Sem_F11 ,offset=0,size=32}
    | F12  : {id=Sem_F12 ,offset=0,size=32}
    | F13  : {id=Sem_F13 ,offset=0,size=32}
    | F14  : {id=Sem_F14 ,offset=0,size=32}
    | F15  : {id=Sem_F15 ,offset=0,size=32}
    | F16  : {id=Sem_F16 ,offset=0,size=32}
    | F17  : {id=Sem_F17 ,offset=0,size=32}
    | F18  : {id=Sem_F18 ,offset=0,size=32}
    | F19  : {id=Sem_F19 ,offset=0,size=32}
    | F20  : {id=Sem_F20 ,offset=0,size=32}
    | F21  : {id=Sem_F21 ,offset=0,size=32}
    | F22  : {id=Sem_F22 ,offset=0,size=32}
    | F23  : {id=Sem_F23 ,offset=0,size=32}
    | F24  : {id=Sem_F24 ,offset=0,size=32}
    | F25  : {id=Sem_F25 ,offset=0,size=32}
    | F26  : {id=Sem_F26 ,offset=0,size=32}
    | F27  : {id=Sem_F27 ,offset=0,size=32}
    | F28  : {id=Sem_F28 ,offset=0,size=32}
    | F29  : {id=Sem_F29 ,offset=0,size=32}
    | F30  : {id=Sem_F30 ,offset=0,size=32}
    | F31  : {id=Sem_F31 ,offset=0,size=32}
   end

val semantic-fcr-of f =
   case f of
      FCCR  : {id=Sem_FCCR ,offset=0,size=32}
    | FEXR  : {id=Sem_FEXR ,offset=0,size=32}
    | FENR  : {id=Sem_FENR ,offset=0,size=32}
    | FCSR  : {id=Sem_FCSR ,offset=0,size=32}
    | FIR   : {id=Sem_FIR  ,offset=0,size=32}
   end
