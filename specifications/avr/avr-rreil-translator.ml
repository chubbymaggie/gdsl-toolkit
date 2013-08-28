export = translate

val sem-adc bo = do
return void
end

val sem-adiw bo = do
  rd <- rval Unsigned bo.first;
	rr <- rval Unsigned bo.second;
  size <- return (sizeof bo.first);

	r <- mktemp;
	add size r rd rr;

	emit-flag-add-v size rd rr (var r);
	emit-flag-n size (var r);
	emit-flag-z size (var r);
	emit-flag-add-c size rd (var r);
	emit-flag-s;

	write bo.first (var r)
end

val sem-undef-binop bo = do
return void
end

val sem-undef-unop uo = do
return void
end

val sem-unknown = do
return void
end

val emit-flag-add-c sz rd r = do
  cf <- return fCF;
  cmpltu sz cf r rd
end

val emit-flag-add-v sz rd rr r = do
  ov <- return fVF;
	
	t1 <- mktemp;
	t2 <- mktemp;
	t3 <- mktemp;

  xorb sz t1 r rd;
  xorb sz t2 r rr;
  andb sz t3 (var t1) (var t2);
  cmplts sz ov (var t3) (imm 0)
end

val emit-flag-n sz r = do
  nf <- return fNF;

	cmplts sz nf r (imm 0)
end

val emit-flag-z sz r = do
  zf <- return fZF;

	cmpeq sz zf r (imm 0)
end

val emit-flag-s = do
  nf <- return fNF;
  ov <- return fVF;
  sf <- return fSF;

	xorb 1 sf (var nf) (var ov)
end

type signedness =
   Signed
 | Unsigned

val sizeof x =
  case x of
	   REG r: 8
	 | REGHL r: 16
	 | IOREG i: 8
	 | IMM imm: case imm of
	      IMM3 i: 3
	    | IMM4 i: 4
	    | IMM6 i: 6
	    | IMM7 i: 7
	    | IMM8 i: 8
	    | IMM12 i: 12
	    | IMM16 i: 16
	    | IMM22 i: 22
		 end
	 | OPSE o: sizeof o.op
	 | OPDI o: sizeof o.op
  end

val write to from =
  case to of
	   REG r: mov (sizeof to) (semantic-register-of r) from
	 | REGHL r: mov (sizeof to) (@{size=16}(semantic-register-of r.regl)) from
	 | IOREG i: mov (sizeof to) (semantic-register-of i) from
  end

val write-mem size ao v = do
  addr <- rval Unsigned ao;
	store {size=size, address=addr} v
end

val rval sn x = let
  val from-vec sn vec =
	  case sn of
	     Signed: SEM_LIN_IMM {const=sx vec}
	   | Unsigned: SEM_LIN_IMM {const=zx vec}
		end

	val from-imm sn imm =
	  case imm of
	     IMM3 i: from-vec sn i
	   | IMM4 i: from-vec sn i
	   | IMM6 i: from-vec sn i
	   | IMM7 i: from-vec sn i
	   | IMM8 i: from-vec sn i
	   | IMM12 i: from-vec sn i
	   | IMM16 i: from-vec sn i
	   | IMM22 i: from-vec sn i
		end
in
  case x of
	   REG r: return (var (semantic-register-of r))
	 | REGHL r: return (var (@{size=16}(semantic-register-of r.regl)))
	 | IOREG i: return (var (semantic-register-of i))
	 | IMM i: return (from-imm sn i)
	 | OPSE o: case o.se of
	      NONE: rval sn o.op
		  | _: do
	        t <- mktemp;
		      orval <- rval sn o.op;
		      size <- return (sizeof o.op);
		      case o.se of
		         DECR: sub size t orval (imm 1)
		       | _: mov size t orval
		      end;
		      write o.op (var t);
		      case o.se of
		         INCR: add size t orval (imm 1)
		       | _: return void
		      end;
		      return (var t)
	      end end
		| OPDI o: return (SEM_LIN_ADD {opnd1=rval sn o.op, opnd2=from-imm sn o.imm})
	end
end

val semantics insn =
 case insn of
    ADC x: sem-adc x
  | ADD x: sem-undef-binop x
  | ADIW x: sem-adiw x
  | AND x: sem-undef-binop x
  | ANDI x: sem-undef-binop x
  | ASR x: sem-undef-unop x
  | BLD x: sem-undef-binop x
  | BRCC x: sem-undef-unop x
  | BRCS x: sem-undef-unop x
  | BREAK: sem-unknown
  | BREQ x: sem-undef-unop x
  | BRGE x: sem-undef-unop x
  | BRHC x: sem-undef-unop x
  | BRHS x: sem-undef-unop x
  | BRID x: sem-undef-unop x
  | BRIE x: sem-undef-unop x
  | BRLT x: sem-undef-unop x
  | BRMI x: sem-undef-unop x
  | BRNE x: sem-undef-unop x
  | BRPL x: sem-undef-unop x
  | BRTC x: sem-undef-unop x
  | BRTS x: sem-undef-unop x
  | BRVC x: sem-undef-unop x
  | BRVS x: sem-undef-unop x
  | BSET x: sem-undef-unop x
  | BST x: sem-undef-binop x
  | CALL x: sem-undef-unop x
  | CBI x: sem-undef-binop x
  | CBR x: sem-undef-binop x
  | CLC: sem-unknown
  | CLH: sem-unknown
  | CLI: sem-unknown
  | CLN: sem-unknown
  | CLR x: sem-undef-unop x
  | CLS: sem-unknown
  | CLT: sem-unknown
  | CLV: sem-unknown
  | CLZ: sem-unknown
  | COM x: sem-undef-unop x
  | CP x: sem-undef-binop x
  | CPC x: sem-undef-binop x
  | CPI x: sem-undef-binop x
  | CPSE x: sem-undef-binop x
  | DEC x: sem-undef-unop x
  | DES x: sem-undef-unop x
  | EICALL: sem-unknown
  | EIJMP: sem-unknown
  | ELPM x: sem-undef-binop x
  | EOR x: sem-undef-binop x
  | FMUL x: sem-undef-binop x
  | FMULS x: sem-undef-binop x
  | FMULSU x: sem-undef-binop x
  | ICALL: sem-unknown
  | IJMP: sem-unknown
  | IN x: sem-undef-binop x
  | INC x: sem-undef-unop x
  | JMP x: sem-undef-unop x
  | LAC x: sem-undef-binop x
  | LAS x: sem-undef-binop x
  | LAT x: sem-undef-binop x
  | LD x: sem-undef-binop x
  | LDI x: sem-undef-binop x
  | LDS x: sem-undef-binop x
  | LPM x: sem-undef-binop x
  | LSL x: sem-undef-unop x
  | LSR x: sem-undef-unop x
  | MOV x: sem-undef-binop x
  | MOVW x: sem-undef-binop x
  | MUL x: sem-undef-binop x
  | MULS x: sem-undef-binop x
  | MULSU x: sem-undef-binop x
  | NEG x: sem-undef-unop x
  | NOP: sem-unknown
  | OR x: sem-undef-binop x
  | ORI x: sem-undef-binop x
  | OUT x: sem-undef-binop x
  | POP x: sem-undef-unop x
  | PUSH x: sem-undef-unop x
  | RCALL x: sem-undef-unop x
  | RET: sem-unknown
  | RETI: sem-unknown
  | RJMP x: sem-undef-unop x
  | ROL x: sem-undef-unop x
  | ROR x: sem-undef-unop x
  | SBC x: sem-undef-binop x
  | SBCI x: sem-undef-binop x
  | SBI x: sem-undef-binop x
  | SBIC x: sem-undef-binop x
  | SBIS x: sem-undef-binop x
  | SBIW x: sem-undef-binop x
  | SBR x: sem-undef-binop x
  | SBRC x: sem-undef-binop x
  | SBRS x: sem-undef-binop x
  | SEC: sem-unknown
  | SEH: sem-unknown
  | SEI: sem-unknown
  | SEN: sem-unknown
  | SES: sem-unknown
  | SET: sem-unknown
  | SEV: sem-unknown
  | SEZ: sem-unknown
  | SLEEP: sem-unknown
  | SPM x: sem-undef-unop x
  | ST x: sem-undef-binop x
  | STS x: sem-undef-binop x
  | SUB x: sem-undef-binop x
  | SUBI x: sem-undef-binop x
  | SWAP x: sem-undef-unop x
  | TST x: sem-undef-unop x
  | WDR: sem-unknown
  | XCH x: sem-undef-binop x
end

val translate insn = do
  update@{stack=SEM_NIL,tmp=0,lab=0,mode64='1'};
#case 0 of 1: return 0 end;
  semantics insn;
  stack <- query $stack;
  return (rreil-stmts-rev stack)
end