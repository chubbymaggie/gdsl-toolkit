# vim:ts=3:sw=3:expandtab

export pretty : (insndata) -> rope

val pretty insdata = show/instruction insdata.insn

val -++ a b = a +++ " " +++ b

val show/instruction insn = show/mnemonic insn

val show/mnemonic insn =
   case insn of
      ADC m: "ADC"
    | ADD m: "ADD"
    | AND m: "AND"
    | BIC m: "BIC"
    | CMN m: "CMN"
    | CMP m: "CMP"
    | EOR m: "EOR"
    | MOV m: "MOV"
    | MVN m: "MVN"
    | ORR m: "ORR"
    | RSB m: "RSB"
    | RSC m: "RSC"
    | SBC m: "SBC"
    | SUB m: "SUB"
    | TEQ m: "TEQ"
    | TST m: "TST"
    | MLA m: "MLA"
    | MUL m: "MUL"
    | SMLAL m: "SMLAL"
    | SMULL m: "SMULL"
    | UMLAL m: "UMULL"
    | STR m: "STR"
    | LDR m: "LDR"
    | LDRH m: "LDRH"
    | STRH m: "STRH"
    | LDRSB m: "LDRSB"
    | LDRSRH m: "LDRSRH"
    | PUSH m: "PUSH"
    | B m: "B"
    | BL m: "BL"
    | BLX_imm m: "BLX (immediate)"
    | BLX_reg m: "BLX (register)"
    | BX m: "BX"
    | BXJ m: "BXJ"
    | MRS m: "MRS"
    | MSR m: "MSR"
    | CLREX: "CLREX"
    | NOP m: "NOP"
    | _: "???"
   end

