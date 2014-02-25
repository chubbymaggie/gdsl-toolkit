val registers-live-map = let #Todo: Segment base addresses
	val add-sem map reg-sem = do
   return (fmap-add-range map reg-sem.id reg-sem.size reg-sem.offset)
	end
	val add map r = do
	 reg-sem <- return (semantic-register-of r);
   add-sem map reg-sem
	end
in do
  map <- return (fmap-empty {});

#  map <- add map AL;
#  map <- add map AH;
#  map <- add map AX;
#  map <- add map EAX;
  map <- add map RAX;
#  map <- add map BL;
#  map <- add map BH;
#  map <- add map BX;
#  map <- add map EBX;
  map <- add map RBX;
#  map <- add map CL;
#  map <- add map CH;
#  map <- add map CX;
#  map <- add map ECX;
  map <- add map RCX;
#  map <- add map DL;
#  map <- add map DH;
#  map <- add map DX;
#  map <- add map EDX;
  map <- add map RDX;
#  map <- add map R8B;
#  map <- add map R8L;
#  map <- add map R8D;
  map <- add map R8;
#  map <- add map R9B;
#  map <- add map R9L;
#  map <- add map R9D;
  map <- add map R9;
#  map <- add map R10B;
#  map <- add map R10L;
#  map <- add map R10D;
  map <- add map R10;
#  map <- add map R11B;
#  map <- add map R11L;
#  map <- add map R11D;
  map <- add map R11;
#  map <- add map R12B;
#  map <- add map R12L;
#  map <- add map R12D;
  map <- add map R12;
#  map <- add map R13B;
#  map <- add map R13L;
#  map <- add map R13D;
  map <- add map R13;
#  map <- add map R14B;
#  map <- add map R14L;
#  map <- add map R14D;
  map <- add map R14;
#  map <- add map R15B;
#  map <- add map R15L;
#  map <- add map R15D;
  map <- add map R15;
#  map <- add map SP;
#  map <- add map ESP;
  map <- add map RSP;
#  map <- add map BP;
#  map <- add map EBP;
  map <- add map RBP;
#  map <- add map SI;
#  map <- add map ESI;
  map <- add map RSI;
#  map <- add map DI;
#  map <- add map EDI;
  map <- add map RDI;
#  map <- add map XMM0;
#  map <- add map XMM1;
#  map <- add map XMM2;
#  map <- add map XMM3;
#  map <- add map XMM4;
#  map <- add map XMM5;
#  map <- add map XMM6;
#  map <- add map XMM7;
#  map <- add map XMM8;
#  map <- add map XMM9;
#  map <- add map XMM10;
#  map <- add map XMM11;
#  map <- add map XMM12;
#  map <- add map XMM13;
#  map <- add map XMM14;
#  map <- add map XMM15;
  map <- add map YMM0;
  map <- add map YMM1;
  map <- add map YMM2;
  map <- add map YMM3;
  map <- add map YMM4;
  map <- add map YMM5;
  map <- add map YMM6;
  map <- add map YMM7;
  map <- add map YMM8;
  map <- add map YMM9;
  map <- add map YMM10;
  map <- add map YMM11;
  map <- add map YMM12;
  map <- add map YMM13;
  map <- add map YMM14;
  map <- add map YMM15;
  map <- add map MM0;
  map <- add map MM1;
  map <- add map MM2;
  map <- add map MM3;
  map <- add map MM4;
  map <- add map MM5;
  map <- add map MM6;
  map <- add map MM7;
  map <- add map ES;
  map <- add map SS;
  map <- add map DS;
  map <- add map FS;
  map <- add map GS;
  map <- add map CS;
  map <- add map ST0;
  map <- add map ST1;
  map <- add map ST2;
  map <- add map ST3;
  map <- add map ST4;
  map <- add map ST5;
  map <- add map ST6;
  map <- add map ST7;
  map <- add map RIP;

  map <- add map FLAGS;
  map <- add-sem map {id=VIRT_LES,offset=0,size=1};
  map <- add-sem map {id=VIRT_LEU,offset=0,size=1};
  map <- add-sem map {id=VIRT_LTS,offset=0,size=1};

	return map
end end
