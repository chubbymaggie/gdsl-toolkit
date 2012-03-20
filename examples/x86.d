granularity = 8
export = main

# Optional arguments
#
# Limit:
#   - Restricts the maximium size of the decode-stream
# Recursion-depth:
#   - Annotate the maximum number of recursion steps for
#     the given decoder. This way, we can compute an upper
#     bound for the maximum used storage for the emitted AST.
#     Additionally, the decoder may fail if during runtime
#     a recrusion depth violation occurs.
#
# limit = 120
# recursion-depth = main = 4

# The state of the decode monad
state =
   {mode64:1='0',
    repne:1='0',
    rep:1='0',
    rex:1='0',
    rexw:1='0',
    rexb:1='0',
    rexr:1='0',
    rexx:1='0',
    vexm:5='00001',
    vexv:4='0000',
    vexl:1='0',
    vexp:2='00',
    opndsz:1='0',
    addrsz:1='0',
    segment:register=DS}

val sel1 & sel2 = 
   let val a s = sel1 s && sel2 s
   in 
      a
   end

val / sel =
   let val a s = not (sel s)
   in
      a
   end

val opndsz? s = $opndsz s
val addrsz? s = $addrsz s
val repne? s = $repne s
val rep? s = $rep s
val rexw? s = $rexw s
val rex? s = $rex s

datatype size =
	B | W | DW | QW | DQW

datatype register =
   AL | AH | AX | EAX | RAX
 | BL | BH | BX | EBX | RBX
 | CL | CH | CX | ECX | RCX
 | DL | DH | DX | EDX | RDX
 | R8L | R8W | R8D | R8 
 | R9L | R9W | R9D | R9 
 | R10L | R10W | R10D | R10 
 | R11L | R11W | R11D | R11 
 | R12L | R12W | R12D | R12 
 | R13L | R13W | R13D | R13 
 | R14L | R14W | R14D | R14 
 | R15L | R15W | R15D | R15 
 | SP | ESP | RSP
 | BP | EBP | RBP
 | SI | ESI | RSI
 | DI | EDI | RDI
 | XMM0
 | XMM1
 | XMM2
 | XMM3
 | XMM4
 | XMM5
 | XMM6
 | XMM7
 | XMM8
 | XMM9
 | XMM10
 | XMM11
 | XMM12
 | XMM13
 | XMM14
 | XMM15
 | YMM0
 | YMM1
 | YMM2
 | YMM3
 | YMM4
 | YMM5
 | YMM6
 | YMM7
 | YMM8
 | YMM9
 | YMM10
 | YMM11
 | YMM12
 | YMM13
 | YMM14
 | YMM15
 | MM0
 | MM1
 | MM2
 | MM3
 | MM4
 | MM5
 | MM6
 | MM7
 | MM8
 | MM9
 | MM10
 | MM11
 | MM12
 | MM13
 | MM14
 | MM15
 | ES
 | SS
 | DS
 | FS
 | GS
 | CS

datatype opnd =
   IMM8 of 8
 | IMM16 of 16
 | IMM32 of 32
 | IMM64 of 64
 | REG of register
 | MEM of {sz: int, segment: register, opnd: opnd}
 | SUM of {a:opnd, b:opnd}
 | SCALE of {imm:2, opnd:opnd}

val al = return (REG AL)
val ah = return (REG AH)
val ax = return (REG AX)
val eax = return (REG EAX)
val rax = return (REG RAX)
val bl = return (REG BL)
val bh = return (REG BH)
val bx = return (REG BX)
val ebx = return (REG EBX)
val rbx = return (REG RBX)
val cl = return (REG CL)
val ch = return (REG CH)
val cx = return (REG CX)
val ecx = return (REG ECX)
val rcx = return (REG RCX)
val dl = return (REG DL)
val dh = return (REG DH)
val dx = return (REG DX)
val edx = return (REG EDX)
val rdx = return (REG RDX)
val sp = return (REG SP)
val esp = return (REG ESP)
val rsp = return (REG RSP)
val bp = return (REG BP)
val ebp = return (REG EBP)
val rbp = return (REG RBP)
val si = return (REG SI)
val esi = return (REG ESI)
val rsi = return (REG RSI)
val di = return (REG DI)
val edi = return (REG EDI)
val rdi = return (REG RDI)
val mm0 = return (REG MM0)
val mm1 = return (REG MM1)
val mm2 = return (REG MM2)
val mm3 = return (REG MM3)
val mm4 = return (REG MM4)
val mm5 = return (REG MM5)
val mm6 = return (REG MM6)
val mm7 = return (REG MM7)
val mm8 = return (REG MM8)
val mm9 = return (REG MM9)
val mm10 = return (REG MM10)
val mm11 = return (REG MM11)
val mm12 = return (REG MM12)
val mm13 = return (REG MM13)
val mm14 = return (REG MM14)
val mm15 = return (REG MM15)
val xmm0 = return (REG XMM0)
val xmm1 = return (REG XMM1)
val xmm2 = return (REG XMM2)
val xmm3 = return (REG XMM3)
val xmm4 = return (REG XMM4)
val xmm5 = return (REG XMM5)
val xmm6 = return (REG XMM6)
val xmm7 = return (REG XMM7)
val xmm8 = return (REG XMM8)
val xmm9 = return (REG XMM9)
val xmm10 = return (REG XMM10)
val xmm11 = return (REG XMM11)
val xmm12 = return (REG XMM12)
val xmm13 = return (REG XMM13)
val xmm14 = return (REG XMM14)
val xmm15 = return (REG XMM15)
val ymm0 = return (REG YMM0)
val ymm1 = return (REG YMM1)
val ymm2 = return (REG YMM2)
val ymm3 = return (REG YMM3)
val ymm4 = return (REG YMM4)
val ymm5 = return (REG YMM5)
val ymm6 = return (REG YMM6)
val ymm7 = return (REG YMM7)
val ymm8 = return (REG YMM8)
val ymm9 = return (REG YMM9)
val ymm10 = return (REG YMM10)
val ymm11 = return (REG YMM11)
val ymm12 = return (REG YMM12)
val ymm13 = return (REG YMM13)
val ymm14 = return (REG YMM14)
val ymm15 = return (REG YMM15)

# A type alias used for instructions taking two arguments
type binop = {opnd1:opnd, opnd2:opnd}
type trinop = {opnd1:opnd, opnd2:opnd, opnd3:opnd}

datatype insn =
   ADD of binop
 | CVTPD2PI of binop
 | MASKMOVDQU of binop
 | VMASKMOVDQU of binop
 | MASKMOVQ of binop
 | MAXPD of binop
 | VMAXPD of trinop
 | MAXPS of binop
 | VMAXPS of trinop
 | MAXSD of binop
 | VMAXSD of trinop
 | MAXSS of binop
 | VMAXSS of trinop
 | MFENCE
 | MINPD of binop
 | VMINPD of trinop
 | MINPS of binop
 | VMINPS of trinop
 | MINSD of binop
 | VMINSD of trinop
 | MINSS of binop
 | VMINSS of trinop
 | MONITOR
 | MOV of binop
 | MOVAPD of binop
 | VMOVAPD of binop
 | MOVAPS of binop
 | VMOVAPS of binop
 | MOVBE of binop
 | MOVD of binop
 | VMOVD of binop
 | MOVQ of binop
 | VMOVQ of binop
 | MOVDDUP of binop
 | VMOVDDUP of binop
 | MOVDQA of binop
 | VMOVDQA of binop
 | MOVDQU of binop
 | VMOVDQU of binop
 | MOVDQ2Q of binop
 | MOVHLPS of binop
 | VMOVHLPS of trinop
 | MOVHPD of binop
 | VMOVHPD of trinop
 | VBMOVHPD of binop
 | MOVHPS of binop
 | VMOVHPS of trinop
 | VBMOVHPS of binop
 | MOVLHPS of binop
 | VMOVLHPS of trinop

 | PHADDW of binop
 | VPHADDW of trinop
 | PHADDD of binop
 | VPHADDD of trinop
 | XADD of binop

val imm8 ['b:8'] = return (IMM8 b)
val imm16 ['b1:8' 'b2:8'] = return (IMM16 (b1 ^ b2))
val imm32 ['b1:8' 'b2:8' 'b3:8' 'b4:8'] = return (IMM32 (b1 ^ b2 ^ b3 ^ b4))
val imm64 ['b1:8' 'b2:8' 'b3:8' 'b4:8' 'b5:8' 'b6:8' 'b7:8' 'b8:8'] =
   return (IMM64 (b1 ^ b2 ^ b3 ^ b4 ^ b5 ^ b6 ^ b7 ^ b8))

## Convert a bit-vectors to registers

val reg8 n =
   case n of
      '000': REG AL
    | '001': REG CL
    | '010': REG DL
    | '011': REG BL
    | '100': REG AH
    | '101': REG CH
    | '110': REG DH
    | '111': REG BH
   end

val reg8r n =
   case n of
      '000': REG R8L
    | '001': REG R10L
    | '010': REG R11L
    | '011': REG R9L
    | '100': REG R12L
    | '101': REG R13L
    | '110': REG R14L
    | '111': REG R15L
   end

val reg8? rex =
   if rex then reg8r else reg8

val reg8F n = (reg8? (prefix n)) (suffix n)

val reg16 n =
   case n of
      '000': REG AX
    | '001': REG CX
    | '010': REG DX
    | '011': REG BX
    | '100': REG SP
    | '101': REG BP
    | '110': REG SI
    | '111': REG DI
   end

val reg16r n =
   case n of
      '000': REG R8L
    | '001': REG R10L
    | '010': REG R11L
    | '011': REG R9L
    | '100': REG R12L
    | '101': REG R13L
    | '110': REG R14L
    | '111': REG R15L
   end

val reg16? rex =
   if rex then reg16r else reg16

val reg16F n = (reg16? (prefix n)) (suffix n)

val reg32 n =
   case n of
      '000': REG EAX
    | '001': REG ECX
    | '010': REG EDX
    | '011': REG EBX
    | '100': REG ESP
    | '101': REG EBP
    | '110': REG ESI
    | '111': REG EDI
   end

val reg32r n =
   case n of
      '000': REG R8D
    | '001': REG R10D
    | '010': REG R11D
    | '011': REG R9D
    | '100': REG R12D
    | '101': REG R13D
    | '110': REG R14D
    | '111': REG R15D
   end

val reg32? rex =
   if rex then reg32r else reg32

val reg32F n = (reg32? (prefix n)) (suffix n)

val reg64 n =
   case n of
      '000': REG RAX
    | '001': REG RCX
    | '010': REG RDX
    | '011': REG RBX
    | '100': REG RSP
    | '101': REG RBP
    | '110': REG RSI
    | '111': REG RDI
   end

val reg64r n =
   case n of
      '000': REG R8
    | '001': REG R10
    | '010': REG R11
    | '011': REG R9
    | '100': REG R12
    | '101': REG R13
    | '110': REG R14
    | '111': REG R15
   end

val reg64? rex =
   if rex then reg64r else reg64

val reg64F n = (reg64? (prefix n)) (suffix n)

val sreg3 n =
   case n of
      '000': REG ES
    | '001': REG CS
    | '010': REG SS
    | '011': REG DS
    | '100': REG FS
    | '101': REG GS
#| '110': reserved
#| '111': reserved
   end

val sreg3? rex = sreg3

val xmm n =
   case n of
      '000': REG XMM0
    | '001': REG XMM1
    | '010': REG XMM2
    | '011': REG XMM3
    | '100': REG XMM4
    | '101': REG XMM5
    | '110': REG XMM6
    | '111': REG XMM7
   end

val xmmr n =
   case n of
      '000': REG XMM8
    | '001': REG XMM9
    | '010': REG XMM10
    | '011': REG XMM11
    | '100': REG XMM12
    | '101': REG XMM13
    | '110': REG XMM14
    | '111': REG XMM15
   end

val xmm? rex =
   if rex then xmmr else xmm

val xmmF n = (xmm? (prefix n)) (suffix n)

val ymm n =
   case n of
      '000': REG YMM0
    | '001': REG YMM1
    | '010': REG YMM2
    | '011': REG YMM3
    | '100': REG YMM4
    | '101': REG YMM5
    | '110': REG YMM6
    | '111': REG YMM7
   end

val ymmr n =
   case n of
      '000': REG YMM8
    | '001': REG YMM9
    | '010': REG YMM10
    | '011': REG YMM11
    | '100': REG YMM12
    | '101': REG YMM13
    | '110': REG YMM14
    | '111': REG YMM15
   end

val ymm? rex =
   if rex then ymmr else ymm

val ymmF n = (ymm? (prefix n)) (suffix n)

val mm n =
   case n of
      '000': REG MM0
    | '001': REG MM1
    | '010': REG MM2
    | '011': REG MM3
    | '100': REG MM4
    | '101': REG MM5
    | '110': REG MM6
    | '111': REG MM7
   end

val mmr n =
   case n of
      '000': REG MM8
    | '001': REG MM9
    | '010': REG MM10
    | '011': REG MM11
    | '100': REG MM12
    | '101': REG MM13
    | '110': REG MM14
    | '111': REG MM15
   end

val mm? rex =
   if rex then mmr else mm

val mmF n = (mm? (prefix n)) (suffix n)

# Deslice the mod/rm byte and put it into the the state

val /0 ['mod:2 000 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=0}
val /1 ['mod:2 001 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=1}
val /2 ['mod:2 010 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=2}
val /3 ['mod:2 011 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=3}
val /4 ['mod:2 100 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=4}
val /5 ['mod:2 101 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=5}
val /6 ['mod:2 110 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=6}
val /7 ['mod:2 111 rm:3'] = update @{mod=mod, rm=rm, reg/opcode=7}
val /r ['mod:2 reg/opcode:3 rm:3'] = update @{mod=mod, reg/opcode=reg/opcode, rm=rm}

## Decoding the SIB byte
#    TODO: this is only for 32bit addressing

val sib-without-index reg? = do
   mod <- query $mod;
   rexb <- query $rexb;
   case mod of
      '00': imm32
    | '01': return ((reg? rexb) '101') # rBP
    | '10': return ((reg? rexb) '101') # rBP
   end
end

val sib-without-base reg? scale index = do
   rexx <- query $rexx;
   let
      val scaled = SCALE{imm=scale, opnd=(reg? rexx) index}
   in
      do
         mod <- query $mod;
	 rexb <- query $rexb;
         case mod of
            '00': 
               do
                  i <- imm32;
                  return (SUM{a=scaled, b=i})
               end
          | _ : return (SUM{a=scaled, b=(reg? rexb) '101'}) # rBP
         end
      end
   end
end

val sib-with-index-and-base reg? s i b = do
   rexx <- query $rexx;
   rexb <- query $rexb;
   return (SUM{a=SCALE{imm=s, opnd=(reg? rexx) i}, b=(reg? rexb) b})
end

val sib ['scale:2 100 101']
 | addrsz? = sib-without-index reg16?
 | otherwise = sib-without-index reg32?

val sib ['scale:2 index:3 101'] 
 | addrsz? = sib-without-base reg16? scale index
 | otherwise = sib-without-base reg32? scale index

val sib ['scale:2 index:3 base:3']
 | addrsz? = sib-with-index-and-base reg16? scale index base
 | otherwise = sib-with-index-and-base reg32? scale index base

## Decoding the mod/rm byte

val addrsz = do
   sz <- query $addrsz;
   case sz of
      '1': return 16
    | '0': return 32
   end
end

val mem op = do
   sz <- addrsz;
   seg <- query $segment;
   return (MEM {sz=sz, segment=seg, opnd=op})
end

val r/m-with-sib = do
   sibOpnd <- sib;
   mod <- query $mod;
   case mod of
      '00': mem sibOpnd
    | '01':
         do
            i <- imm8;
            mem (SUM{a=sibOpnd, b=i})
         end
    | '10':
         do
            i <- imm32;
            mem (SUM{a=sibOpnd, b=i})
         end
   end
end

val r/m-without-sib reg addr-reg = do
   mod <- query $mod;
   rm <- query $rm;
   case mod of
      '00':
         case rm of
            '101':
               do
                  i <- imm32;
                  mem i
               end
          | _ : mem (addr-reg rm)
         end
    | '01':
         do
            i <- imm8;
            mem (SUM{a=addr-reg rm, b=i})
         end
    | '10':
         do
            i <- imm32;
            mem (SUM{a=addr-reg rm, b=i})
         end
    | '11': return (reg rm)
   end
end

val addrReg = do
   addrsz <- query $addrsz;
   case addrsz of
      '0': return reg64?
    | '1': return reg32?
   end
end

val r/m reg? = do
   mod <- query $mod;
   rm <- query $rm;
   rexb <- query $rexb;
   addr-reg? <- addrReg;
   case rm of
      '100': r/m-with-sib
    | _ : r/m-without-sib (reg? rexb) (addr-reg? rexb)
   end
end

val r/m8 = r/m reg8?
val r/m16 = r/m reg16?
val r/m32 = r/m reg32?
val r/m64 = r/m reg64?
val mm/m64 = r/m mm?
val xmm/m128 = r/m xmm?
val xmm/m64 = r/m xmm?
val xmm/m32 = r/m xmm?
val ymm/m256 = r/m ymm?

val reg?/nomem reg? = do
   mod <- query $mod;
   case mod of
      '11': r/m reg?
   end
end
val xmm/nomem128 = reg?/nomem xmm?
val mm/nomem64 = reg?/nomem mm?

val m? r/m? = do
   mod <- query $mod;
   case mod of
      '00': r/m?
    | '01': r/m?
    | '10': r/m?
   end
#   if (unsigned (not mod)) > 0 then r/m? else r/m?
end
val m16 = m? r/m16
val m32 = m? r/m32
val m64 = m? r/m64

val r/ reg? = do
   rexr <- query $rexr;
   r <- query $reg;
   return ((reg? rexr) r)
end

val r8 = r/ reg8?
val r16 = r/ reg16?
val r32 = r/ reg32?
val r64 = r/ reg64?
val mm64 = r/ mm?
val xmm128 = r/ xmm?
val ymm256 = r/ ymm?

val vex/'mm mmF = do
   vexv <- query $vexv;
   return (mmF (not vexv))
end
val vex/xmm = vex/'mm xmmF
val vex/ymm = vex/'mm ymmF

val moffs8 = do
   i <- imm8;
   mem i
end

val moffs16 = do
   i <- imm16;
   mem i
end

val moffs32 = do
   i <- imm32;
   mem i
end

val moffs64 = do
   i <- imm64;
   mem i
end

val binop cons giveOp1 giveOp2 = do
   op1 <- giveOp1;
   op2 <- giveOp2;
   return (cons {op1=op1, op2=op2})
   # We could add syntatic sugar for record field creation:
   #   return (MOV {op1, op2})
end

val trinop cons giveOp1 giveOp2 giveOp3 = do
   op1 <- giveOp1;
   op2 <- giveOp2;
   op3 <- giveOp3;
   return (cons {op1=op1, op2=op2, op3=op3})
end

val add = binop ADD
val cvtpdf2pi = binop CVTPD2PI
val maskmovdqu = binop MASKMOVDQU
val vmaskmovdqu = binop VMASKMOVDQU
val maskmovq = binop MASKMOVQ
val maxpd = binop MAXPD
val vmaxpd = trinop VMAXPD
val maxps = binop MAXPS
val vmaxps = trinop VMAXPS
val maxsd = binop MAXSD
val vmaxsd = trinop VMAXSD
val maxss = binop MAXSS
val vmaxss = trinop VMAXSS
val mfence = return MFENCE
val minpd = binop MINPD
val vminpd = trinop VMINPD
val minps = binop MINPS
val vminps = trinop VMINPS
val minsd = binop MINSD
val vminsd = trinop VMINSD
val minss = binop MINSS
val vminss = trinop VMINSS
val monitor = return MONITOR
val mov = binop MOV
val movapd = binop MOVAPD
val vmovapd = binop VMOVAPD
val movaps = binop MOVAPS
val vmovaps = binop VMOVAPS
val movbe = binop MOVBE
val movd = binop MOVD
val vmovd = binop VMOVD
val movq = binop MOVQ
val vmovq = binop VMOVQ
val movddup = binop MOVDDUP
val vmovddup = binop VMOVDDUP
val movdqa = binop MOVDQA
val vmovdqa = binop VMOVDQA
val movdqu = binop MOVDQU
val vmovdqu = binop VMOVDQU
val movdq2q = binop MOVDQ2Q
val movhlps = binop MOVHLPS
val vmovhlps = trinop VMOVHLPS
val movhpd = binop MOVHPD
val vmovhpd = trinop VMOVHPD
val vbmovhpd = binop VBMOVHPD
val movhps = binop MOVHPS
val vmovhps = trinop VMOVHPS
val vbmovhps = binop VBMOVHPS
val movlhps = binop MOVLHPS
val vmovlhps = trinop VMOVLHPS

val phaddw = binop PHADDW
val vphaddw = trinop VPHADDW
val phaddd = binop PHADDD
val vphaddd = trinop VPHADDD
val xadd = binop XADD

## The VEX prefixes

val vex-pp pp =
   case pp of
      '01': update @{opndsz='1'}
#    | '10': => F3 Prefix
#    | '11': => F2 Prefix
   end

val /vex [0xc4 'r:1 x:1 b:1 m:5' 'w:1 v:4 l:1 pp:2']
 | / rex? = do
   update @{rexr=r, rexx=x, rexb=b, vexm=m, rexw=w, vexv=v, vexl=l, vexp=pp};
   vex-pp pp
end

val /vex [0xc5 'r:1 v:4 l:1 pp:2']
 | / rex? = do
   update @{rexr=r, vexv=v, vexl=l, vexp=pp};
   vex-pp pp
end

val vex-128? s = $vexl s
val vex-256? s = not ($vexl s)
val vex-noreg? s = ($vexv s) == '1111'
val vex-no-simd? s = ($vexp s) == '00'
val vex-66? s = ($vexp s) == '01'
val vex-f2? s = ($vexp s) == '11'
val vex-f3? s = ($vexp s) == '10'

# Rückgabewert in Pattern??

## The REX prefixes

val /rex ['0100 w:1 r:1 x:1 b:1'] = update @{rex='1', rexw=w, rexb=b, rexx=x, rexr=r}

## Decode prefixes, recursion could be limited with "recursion-depth main = 4" 

val main [0x2e] = do update @{segment=CS}; main end
val main [0x36] = do update @{segment=SS}; main end
val main [0x3e] = do update @{segment=DS}; main end
val main [0x26] = do update @{segment=ES}; main end
val main [0x64] = do update @{segment=FS}; main end
val main [0x65] = do update @{segment=GS}; main end
val main [0x66] = do update @{opndsz='1'}; main end
val main [0x67] = do update @{addrsz='1'}; main end
val main [0xf2] = do update @{repne='1'}; main end
val main [0xf3] = do update @{rep='1'}; main end

val main [0x66 0x0f 0x38] = three-byte-opcode-0f-38
val main [0x66 /rex 0x0f 0x38] = three-byte-opcode-0f-38
val main [0x66 0x0f] = two-byte-opcode-0f 
val main [0x66 /rex 0x0f] = two-byte-opcode-0f 
val main [/rex] = one-byte-opcode
val main [] = one-byte-opcode
val main [/vex] = do
   vexm <- query $vexm;
   case vexm of
      '00001': two-byte-opcode-0f-vex
    | '00010': three-byte-opcode-0f-38-vex
#   | '00011': three-byte-opcode-0f-3a-vex
#   | _: one-byte-opcode
    end
end

## Instruction decoders

## One Byte Opcodes
## Two Byte Opcodes with Prefix 0x0f
## Three Byte Opcodes with Prefix 0x0f38

### ADD Vol. 2A 3-35
val one-byte-opcode [0x04] = add al imm8
val one-byte-opcode [0x05]
 | rexw? = add rax imm64
 | opndsz? = add ax imm16
 | otherwise = add eax imm32
val one-byte-opcode [0x80 /0] = add r/m8 imm8
val one-byte-opcode [0x81 /0]
 | rexw? = add r/m64 imm64
 | opndsz? = add r/m16 imm16
 | otherwise = add r/m32 imm32
val one-byte-opcode [0x83 /0]
 | rexw? = add r/m64 imm8
 | opndsz? = add r/m16 imm8
 | otherwise = add r/m32 imm8
val one-byte-opcode [0x00 /r] = add r/m8 r8
val one-byte-opcode [0x01 /0]
 | rexw? = add r/m64 r64
 | opndsz? = add r/m16 r16
 | otherwise = add r/m32 r32
val one-byte-opcode [0x02 /r] = add r8 r/m8
val one-byte-opcode [0x03 /0]
 | rexw? = add r64 r/m64
 | opndsz? = add r16 r/m16
 | otherwise = add r32 r/m32

### CVTPD2PI Vol 2A 3-248
val two-byte-opcode-0f-66 [0x2d /r] 
 | opndsz? = cvtpdf2pi mm64 xmm/m128

### MASKMOVDQU Vol. 2B 4-9
val two-byte-opcode-0f [0xf7 /r] 
 | opndsz? = maskmovdqu xmm128 xmm/nomem128
val two-byte-opcode-0f-vex [0xf7 /r] 
 | vex-noreg? & vex-128? & vex-66? = vmaskmovdqu xmm128 xmm/nomem128

### MASKMOVQ Vol. 2B 4-11
val two-byte-opcode-0f [0xf7 /r]
 | / opndsz? = maskmovq mm64 mm/nomem64

### MAXPD Vol. 2B 4-13
val two-byte-opcode-0f [0x5f /r] 
 | / opndsz? = maxpd xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-128? & vex-66? = vmaxpd xmm128 vex/xmm xmm/m128
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-256? & vex-66? = vmaxpd ymm256 vex/ymm ymm/m256

### MAXPS 4-16 Vol. 2B
val two-byte-opcode-0f [0x5f /r] 
 | / opndsz? = maxps xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-128? & vex-no-simd? = vmaxps xmm128 vex/xmm xmm/m128
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-256? & vex-no-simd? = vmaxps ymm256 vex/ymm ymm/m256

### MAXSD Vol. 2B 4-19
val two-byte-opcode-0f [0x5f /r] 
 | / repne? = maxsd xmm128 xmm/m64
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-f2? = vmaxsd xmm128 vex/xmm xmm/m64

### MAXSS Vol. 2B 4-21
val two-byte-opcode-0f [0x5f /r] 
 | / rep? = maxss xmm128 xmm/m32
val two-byte-opcode-0f-vex [0x5f /r] 
 | vex-f3? = vmaxss xmm128 vex/xmm xmm/m32

### MFENCE Vol. 2B 4-23
val two-byte-opcode-0f [0xae /6] = mfence

### MINPD Vol. 2B 4-25
val two-byte-opcode-0f [0x5d /r] 
 | / opndsz? = minpd xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-128? & vex-66? = vminpd xmm128 vex/xmm xmm/m128
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-256? & vex-66? = vminpd ymm256 vex/ymm ymm/m256

### MINPS Vol. 2B 4-28
val two-byte-opcode-0f [0x5d /r] 
 | / opndsz? = minps xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-128? & vex-no-simd? = vminps xmm128 vex/xmm xmm/m128
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-256? & vex-no-simd? = vminps ymm256 vex/ymm ymm/m256

### MINSD Vol. 2B 4-31
val two-byte-opcode-0f [0x5d /r] 
 | / repne? = minsd xmm128 xmm/m64
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-f2? = vminsd xmm128 vex/xmm xmm/m64

### MINSS Vol. 2B 4-33
val two-byte-opcode-0f [0x5d /r] 
 | / rep? = minss xmm128 xmm/m32
val two-byte-opcode-0f-vex [0x5d /r] 
 | vex-f3? = vminss xmm128 vex/xmm xmm/m32

### MONITOR Vol. 2B 4-35
val two-byte-opcode-0f [0xae 0x01 0xc8] = monitor

### MOV Vol 2A 3-643
val one-byte-opcode [0x88 /r] = mov r/m8 r8
val one-byte-opcode [0x89 /r] 
 | opndsz? = mov r/m16 r16
#| rexw? = mov r/m64 r64
 | otherwise = mov r/m32 r32
val one-byte-opcode [0x8a /r] = mov r8 r/m8
val one-byte-opcode [0x8b /r]
 | opndsz? = mov r16 r/m16
 | otherwise = mov r32 r/m32
val one-byte-opcode [0x8c /r] = mov r/m16 (r/ sreg3?)
val one-byte-opcode [0x8e /r] = mov (r/ sreg3?) r/m16
val one-byte-opcode [0xa0] = mov al moffs8 
val one-byte-opcode [0xa1]
 | addrsz? = mov ax moffs16
 | otherwise = mov eax moffs32
val one-byte-opcode [0xa2] = mov moffs8 al
val one-byte-opcode [0xa3]
 | addrsz? = mov moffs16 ax
 | otherwise = mov moffs32 eax
val one-byte-opcode [0xb0] = mov al imm8
val one-byte-opcode [0xb1] = mov cl imm8
val one-byte-opcode [0xb2] = mov dl imm8
val one-byte-opcode [0xb3] = mov bl imm8
val one-byte-opcode [0xb4] = mov ah imm8
val one-byte-opcode [0xb5] = mov ch imm8
val one-byte-opcode [0xb6] = mov dh imm8
val one-byte-opcode [0xb7] = mov bh imm8
val one-byte-opcode [0xb8]
 | opndsz? = mov ax imm16
 | otherwise = mov eax imm32
val one-byte-opcode [0xb9]
 | opndsz? = mov cx imm16
 | otherwise = mov ecx imm32
val one-byte-opcode [0xba]
 | opndsz? = mov dx imm16
 | otherwise = mov edx imm32
val one-byte-opcode [0xbb]
 | opndsz? = mov bx imm16
 | otherwise = mov ebx imm32
val one-byte-opcode [0xbc]
 | opndsz? = mov sp imm16
 | otherwise = mov esp imm32
val one-byte-opcode [0xbd]
 | opndsz? = mov bp imm16
 | otherwise = mov ebp imm32
val one-byte-opcode [0xbe]
 | opndsz? = mov si imm16
 | otherwise = mov esi imm32
val one-byte-opcode [0xbf]
 | opndsz? = mov di imm16
 | otherwise = mov edi imm32
val one-byte-opcode [0xC6 /0] = mov r/m8 imm8
val one-byte-opcode [0xC7 /0]
 | opndsz? = mov r/m16 imm16
 | otherwise = mov r/m32 imm32

### MOVAPD Vol. 2B 4-52
val two-byte-opcode-0f [0x28 /r] 
 | opndsz? = movapd xmm128 xmm/m128
val two-byte-opcode-0f [0x29 /r] 
 | opndsz? = movapd xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x28 /r] 
 | vex-noreg? & vex-128? & vex-66? = vmovapd xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x29 /r] 
 | vex-noreg? & vex-128? & vex-66? = vmovapd xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x28 /r] 
 | vex-noreg? & vex-256? & vex-66? = vmovapd ymm256 ymm/m256
val two-byte-opcode-0f-vex [0x29 /r] 
 | vex-noreg? & vex-256? & vex-66? = vmovapd ymm/m256 ymm256

### MOVAPS Vol. 2B 4-55
val two-byte-opcode-0f [0x28 /r] 
 | / opndsz? = movaps xmm128 xmm/m128
val two-byte-opcode-0f [0x29 /r] 
 | / opndsz? = movaps xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x28 /r] 
 | vex-noreg? & vex-128? & vex-no-simd? = vmovaps xmm128 xmm/m128
val two-byte-opcode-0f-vex [0x29 /r] 
 | vex-noreg? & vex-128? & vex-no-simd? = vmovaps xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x28 /r] 
 | vex-noreg? & vex-256? & vex-no-simd? = vmovaps ymm256 ymm/m256
val two-byte-opcode-0f-vex [0x29 /r] 
 | vex-noreg? & vex-256? & vex-no-simd? = vmovaps ymm/m256 ymm256

### MOVBE Vol. 2B 4-58
val three-byte-opcode-0f-38 [0xf0 /r]
 | rexw? = movbe r64 m64
 | opndsz? = movbe r16 m16
 | otherwise = movbe r32 m32
val three-byte-opcode-0f-38 [0xf1 /r]
 | rexw? = movbe m64 r64
 | opndsz? = movbe m16 r16
 | otherwise = movbe m32 r32

### MOVD/MOVQ Vol. 2B 4-61
val two-byte-opcode-0f [0x6e /r]
 | / opndsz? & rexw? = movq mm64 r/m64
 | / opndsz? & / rexw? = movd mm64 r/m32
val two-byte-opcode-0f [0x7e /r]
 | / opndsz? & rexw? = movq r/m64 mm64
 | / opndsz? & / rexw? = movd r/m32 mm64
val two-byte-opcode-0f-vex [0x6e /r]
 | vex-noreg? & vex-128? & vex-66? & / rexw? = vmovd xmm128 r/m32
 | vex-noreg? & vex-128? & vex-66? & rexw? = vmovd xmm128 r/m64
val two-byte-opcode-0f [0x6e /r]
 | opndsz? & rexw? = movq xmm128 r/m64
 | opndsz? & / rexw? = movd xmm128 r/m32
val two-byte-opcode-0f [0x7e /r]
 | opndsz? & rexw? = movq r/m64 xmm128
 | opndsz? & / rexw? = movd r/m32 xmm128
val two-byte-opcode-0f-vex [0x7e /r]
 | vex-noreg? & vex-128? & vex-66? & / rexw? = vmovd r/m32 xmm128
 | vex-noreg? & vex-128? & vex-66? & rexw? = vmovd r/m64 xmm128

### MOVDDUP Vol. 2B 4-64
val two-byte-opcode-0f [0x12 /r]
 | repne? = movddup xmm128 xmm/m64
val two-byte-opcode-0f-vex [0x12 /r]
 | vex-noreg? & vex-128? & vex-f2? = vmovddup xmm128 xmm/m64
 | vex-noreg? & vex-256? & vex-f2? = vmovddup ymm256 ymm/m256

### MOVDQA Vol. 2B 4-67
val two-byte-opcode-0f [0x6f /r]
 | opndsz? = movdqa xmm128 xmm/m128
val two-byte-opcode-0f [0x7f /r]
 | opndsz? = movdqa xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x6f /r]
 | vex-noreg? & vex-128? & vex-66? = vmovdqa xmm128 xmm/m128
 | vex-noreg? & vex-256? & vex-66? = vmovdqa ymm256 ymm/m256
val two-byte-opcode-0f-vex [0x7f /r]
 | vex-noreg? & vex-128? & vex-66? = vmovdqa xmm/m128 xmm128
 | vex-noreg? & vex-256? & vex-66? = vmovdqa ymm/m256 ymm256

### MOVDQU Vol. 2B 4-70
val two-byte-opcode-0f [0x6f /r]
 | rep? = movdqu xmm128 xmm/m128
val two-byte-opcode-0f [0x7f /r]
 | rep? = movdqu xmm/m128 xmm128
val two-byte-opcode-0f-vex [0x6f /r]
 | vex-noreg? & vex-128? & vex-f3? = vmovdqu xmm128 xmm/m128
 | vex-noreg? & vex-256? & vex-f3? = vmovdqu ymm256 ymm/m256
val two-byte-opcode-0f-vex [0x7f /r]
 | vex-noreg? & vex-128? & vex-f3? = vmovdqu xmm/m128 xmm128
 | vex-noreg? & vex-256? & vex-f3? = vmovdqu ymm/m256 ymm256

### MOVDQ2Q Vol. 2B 4-73
val two-byte-opcode-0f [0xd6 /r]
 | repne? = movdq2q mm64 xmm128

### MOVHLPS Vol. 2B 4-75
val two-byte-opcode-0f [0x12 /r]
 | / opndsz? = movhlps xmm128 xmm/nomem128
val two-byte-opcode-0f-vex [0x12 /r]
 | vex-128? & vex-no-simd? = vmovhlps xmm128 vex/xmm xmm/nomem128

### MOVHPD Vol. 2B 4-77
val two-byte-opcode-0f [0x16 /r]
 | opndsz? = movhpd xmm128 m64
val two-byte-opcode-0f [0x17 /r]
 | opndsz? = movhpd m64 xmm128
val two-byte-opcode-0f-vex [0x16 /r]
 | vex-128? & vex-66? = vmovhpd xmm128 vex/xmm m64
val two-byte-opcode-0f-vex [0x17 /r]
 | vex-noreg? & vex-128? & vex-66? = vbmovhpd m64 xmm128

### MOVHPS Vol. 2B 4-79
val two-byte-opcode-0f [0x16 /r]
 | / opndsz? = movhps xmm128 m64
val two-byte-opcode-0f [0x17 /r]
 | / opndsz? = movhps m64 xmm128
val two-byte-opcode-0f-vex [0x16 /r]
 | vex-128? & vex-no-simd? = vmovhps xmm128 vex/xmm m64
val two-byte-opcode-0f-vex [0x17 /r]
 | vex-noreg? & vex-128? & vex-no-simd? = vbmovhps m64 xmm128

### MOVLHPS Vol. 2B 4-81
val two-byte-opcode-0f [0x16 /r]
 | / opndsz? = movlhps xmm128 xmm/nomem128
val two-byte-opcode-0f-vex [0x16 /r]
 | vex-128? & vex-no-simd? = vmovlhps xmm128 vex/xmm xmm/nomem128
# FIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIXFIX

### PHADDW/PHADDD Vol. 2B 4-253
val three-byte-opcode-0f-38 [01 /r]
 | opndsz? = phaddw xmm128 xmm/m128
 | otherwise = phaddw mm64 mm/m64
val three-byte-opcode-0f-38 [02 /r]
 | opndsz? = phaddd xmm128 xmm/m128
 | otherwise = phaddd mm64 mm/m64
val three-byte-opcode-0f-38-vex [01 /r]
 | opndsz? & vex-128? & vex-66? = vphaddw xmm128 vex/xmm xmm/m128
val three-byte-opcode-0f-38-vex [02 /r]
 | opndsz? & vex-128? & vex-66? = vphaddd xmm128 vex/xmm xmm/m128

### XADD Vol. 2B 4-667
val two-byte-opcode-0f [0xc0 /r] = xadd r/m8 r8
val two-byte-opcode-0f [0xc1 /r]
 | rexw? = xadd r/m64 r64
 | opndsz? = mov r/m16 r16
 | otherwise = mov r/m32 r32
