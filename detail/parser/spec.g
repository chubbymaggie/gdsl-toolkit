
%name Spec;

%tokens
   : KW_case ("case")
   | KW_in ("in")
   | KW_do ("do")
   | KW_export ("export")
   | KW_else ("else")
   | KW_end ("end")
   | KW_if ("if")
   | KW_let ("let")
   | KW_val ("val")
   | KW_mod ("%")
   | KW_of ("of")
   | KW_granularity ("granularity")
   | KW_raise ("raise")
   | KW_then ("then")
   | KW_type ("type")
   | KW_and ("and")
   | KW_or ("or")
   | MONAD ("S")
   | SMALLER ("<")
   | LARGER (">")
   | WITH ("@")
   | SELECT ("$")
   | BIND ("<-")
   | TO ("->")
   | DOUBLE_TO ("=>")
   | EQ ("=")
   | TICK ("'")
   | DOT (".")
   | UNIT ("()")
   | LP ("(")
   | RP (")")
   | LB ("[")
   | RB ("]")
   | LCB ("{")
   | RCB ("}")
   | CONCAT ("^")
   | PLUS ("+")
   | MINUS ("-")
   | TIMES ("*")
   | TILDE ("~")
   | COMMA (",")
   | SEMI (";")
   | BAR ("|")
   | COLON (":")
   | WILD ("_")
   | BITSTR of string
   | TYVAR of Atom.atom
   | ID of Atom.atom
   | MID of Atom.atom
   | CONS of Atom.atom
   | POSINT of IntInf.int (* positive integer *)
   | HEXINT of int * IntInf.int (* hex number with bit size *)
   | NEGINT of IntInf.int (* negative integer *)
   | FLOAT of FloatLit.float
   | STRING of string
   | SYMBOL of Atom.atom
   ;

%defs (
   structure PT = SpecParseTree

   val sourcemap = CurrentSourcemap.sourcemap

   (* apply a mark constructor to a span and a tree *)
   fun mark cons (span : AntlrStreamPos.span, tr) = cons{span = {file = !sourcemap, span = span}, tree = tr}

   (* specialize mark functions for common node types *)
   val markDecl = mark PT.MARKdecl
   fun markExp (_, e as PT.MARKexp _) = e
     | markExp (sp, tr) = mark PT.MARKexp (sp, tr)
   fun markPat (_, p as PT.MARKpat _) = p
     | markPat (sp, tr) = mark PT.MARKpat (sp, tr)

   (* construct conditional expressions for a list of expressions *)
   fun mkCondExp con = let
      fun mk (e, []) = e
        | mk (e, e'::r) = mk (con(e', e), r)
   in
      mk
   end

   (* build an application for an infix binary operator *)
   fun mkBinApp (e1, rator, e2) = PT.BINARYexp(e1, rator, e2)

   (* construct application expressions for left-associative binary operators *)
   fun mkLBinExp (e, []) = e
     | mkLBinExp (e, (id, e')::r) = mkLBinExp (mkBinApp(e, id, e'), r)

   (* construct application expressions for right-associative binary operators *)
   fun mkRBinExp (e, []) = e
     | mkRBinExp (e, [(id, e')]) = mkBinApp(e, id, e')
     | mkRBinExp (e, (id, e')::r) = mkBinApp(e, id, mkRBinExp(e', r))

   fun mkApply (e, es) =
      case es of
         [] => e
       | es => PT.APPLYexp(e, es)
   
);

Program
   : Decl (";"? Decl)* => (Decl::SR)
   ;

Decl
   : "export" Qid TyVars ":" Ty => (markDecl (FULL_SPAN, PT.EXPORTdecl (Qid,TyVars,Ty)))
   | "type" Name TyVars "=" TyDef => (TyDef (Name, TyVars))
   | "val" Name Name* "=" Exp => (markDecl (FULL_SPAN, PT.LETRECdecl (Name1, Name2, Exp)))
   | "val" Sym Name* "=" Exp => (markDecl (FULL_SPAN, PT.LETRECdecl (Sym, Name, Exp)))
   | "val" (MID Name => ((MID,Name)))* "=" Exp => (
       let
         val (names,args) = ListPair.unzip SR
         val name = Atom.atom (String.concat (List.map Atom.toString names))
      in
         markDecl (FULL_SPAN, PT.LETRECdecl (name, args, Exp))
      end)
   | "val" Name "[" DecodePat* "]" decl=
      ( "=" Exp =>
         (PT.DECODEdecl (Name, DecodePat, Sum.INL Exp))
      | ("|" Exp "=" Exp)+ =>
         (PT.DECODEdecl (Name, DecodePat, Sum.INR SR))) =>
      (markDecl (FULL_SPAN, decl))
   ; 

TyVars
   : "[" Name ("," Name)* "]" => (Name :: SR)
   | (* empty *) => ([])
   ;

TyDef
   : ConDecls => (fn (name,tvars) => markDecl (FULL_SPAN, PT.DATATYPEdecl (name, tvars, ConDecls)))
   | Ty => (fn (name,tvars) => markDecl (FULL_SPAN, PT.TYPEdecl (name, Ty)))
   ;

ConDecls
   : ConDecl ("|" ConDecl)* => (ConDecl::SR)
   ;

ConDecl
   : ConBind ("of" Ty)? => ((ConBind, SR))
   ;

Ty
   : Int => (mark PT.MARKty (FULL_SPAN, PT.BITty Int))
   | "|" Int "|" => (mark PT.MARKty (FULL_SPAN, PT.BITty Int))
   | "|" Qid "|" => (mark PT.MARKty (FULL_SPAN, PT.NAMEDty (Qid,[])))
   | Qid =>
         (mark PT.MARKty (FULL_SPAN, PT.NAMEDty (Qid,[])))
   | Qid "[" TyBind ("," TyBind)* "]"=>
         (mark PT.MARKty (FULL_SPAN, PT.NAMEDty (Qid,TyBind :: SR)))
   | "{" Name ":" Ty ("," Name ":" Ty)* "}" =>
      (mark PT.MARKty (FULL_SPAN, PT.RECORDty ((Name, Ty)::SR)))
   | "{" "}" =>
      (mark PT.MARKty (FULL_SPAN, PT.RECORDty []))
   | "(" Ty ("," Ty)* ")" "->" Ty =>
      (mark PT.MARKty (FULL_SPAN, PT.FUNCTIONty (Ty1::SR,Ty2)))
   | "()" "->" Ty =>
      (mark PT.MARKty (FULL_SPAN, PT.FUNCTIONty ([],Ty)))
   | "()" => (mark PT.MARKty (FULL_SPAN, PT.UNITty))
   | "S" Ty "<" Ty "=>" Ty ">" =>
      (mark PT.MARKty (FULL_SPAN, PT.MONADty (Ty1,Ty2,Ty3)))
   ;

TyBind
   : Qid "=" Ty => ((Qid,Ty))
   | Qid => ((Qid,PT.NAMEDty (Qid,[])))
   ;

DecodePat
   : BitPat => (mark PT.MARKdecodepat (FULL_SPAN, PT.BITdecodepat BitPat))
   | TokPat => (mark PT.MARKdecodepat (FULL_SPAN, PT.TOKENdecodepat TokPat))
   ;

BitPat
   : "'" PrimBitPat+ "'" => (PrimBitPat)
   ;

TokPat
   : HEXINT => (mark PT.MARKtokpat (FULL_SPAN, PT.TOKtokpat HEXINT))
   | Qid => (mark PT.MARKtokpat (FULL_SPAN, PT.NAMEDtokpat Qid))
   ;

PrimBitPat
   : BITSTR => (mark PT.MARKbitpat (FULL_SPAN, PT.BITSTRbitpat BITSTR))
   | Qid (BitPatOrInt)? =>
      (mark
         PT.MARKbitpat
         (FULL_SPAN,
          case SR of
             NONE => PT.NAMEDbitpat Qid
           | SOME i => PT.BITVECbitpat (#tree Qid, i)))
   ;

BitPatOrInt
   : ":" POSINT => (let fun dup n = if n=0 then "" else "." ^ dup (n-1)
                in dup (IntInf.toInt POSINT) end)
   | "@" BITSTR => (BITSTR)
   ;

Exp
   : CaseExp => (CaseExp)
   | MID CaseExp (MID CaseExp)* => (
      let
         val (names, exps) = ListPair.unzip SR
         val name = Atom.atom (String.concat (List.map Atom.toString (MID :: names)))
         val qid = {span={file= !sourcemap, span=MID_SPAN}, tree= name}
         val id = mark PT.MARKexp (MID_SPAN, PT.IDexp qid)
      in
         mark PT.MARKexp (FULL_SPAN, mkApply (id, CaseExp :: exps))
      end
   )
   ;

CaseExp
   : ClosedExp => (ClosedExp)
   | "case" ClosedExp "of" Cases "end" =>
      (mark PT.MARKexp (FULL_SPAN, PT.CASEexp (ClosedExp, Cases)))
   ;

ClosedExp
   : OrElseExp
   | "if" CaseExp "then" CaseExp "else" CaseExp =>
      (mark PT.MARKexp (FULL_SPAN, PT.IFexp (CaseExp1, CaseExp2, CaseExp3)))
(* | "raise" Exp =>
       (mark PT.MARKexp (FULL_SPAN, PT.RAISEexp Exp))
*)
   | "do" MonadicExp (";" MonadicExp)* "end" =>
      (mark PT.MARKexp (FULL_SPAN, PT.SEQexp (MonadicExp::SR)))
   ;

MonadicExp
   : Exp =>
      (mark PT.MARKseqexp (FULL_SPAN, PT.ACTIONseqexp Exp))
   | Name "<-" Exp =>
      (mark PT.MARKseqexp (FULL_SPAN, PT.BINDseqexp (Name, Exp)))
   ;

Cases
   : Pat ":" Exp ("|" Pat ":" Exp)* => ((Pat, Exp)::SR)
   ;

Pat
   : "_" => (mark PT.MARKpat (FULL_SPAN, PT.WILDpat))
   | Int => (mark PT.MARKpat (FULL_SPAN, PT.INTpat Int))
   | Name => (mark PT.MARKpat (FULL_SPAN, PT.IDpat Name))
   | ConUse Pat? => (mark PT.MARKpat (FULL_SPAN, PT.CONpat (ConUse, Pat)))
   | BitPat => (mark PT.MARKpat (FULL_SPAN, PT.BITpat BitPat))
   ;

OrElseExp
   : AndAlsoExp (OrElse AndAlsoExp)* =>
      (mark PT.MARKexp (FULL_SPAN, mkLBinExp (AndAlsoExp, SR)))
   ;

OrElse
   : "or" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.orElse))
   ;

AndAlsoExp
   : RExp (AndAlso RExp)* =>
      (mark PT.MARKexp (FULL_SPAN, mkLBinExp (RExp, SR)))
   ;

AndAlso
   : "and" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.andAlso))
   ;

RExp
   : AExp ((Sym => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Sym))
          ) AExp)* =>
      (mark PT.MARKexp (FULL_SPAN, mkLBinExp(AExp, SR)))
   ;

AExp
   : MExp (( "+" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.plus))
           | "-" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.minus))
          ) MExp => (SR, MExp))* =>
      (mark PT.MARKexp (FULL_SPAN, mkLBinExp (MExp, SR)))
   ;

MExp
   : SelectExp
      (( "*" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.times))
       | "%" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.mod))
       ) ApplyExp =>
      (SR, ApplyExp))* =>
         (mark PT.MARKexp (FULL_SPAN, mkLBinExp (SelectExp, SR)))
   ;

SelectExp
   : ApplyExp 
      (("^" => (mark PT.MARKinfixop (FULL_SPAN, PT.OPinfixop Op.concat))
      ) ApplyExp => (SR, ApplyExp))* =>
      (mark PT.MARKexp (FULL_SPAN, mkLBinExp (ApplyExp, SR)))
   ;

ApplyExp
   : AtomicExp Args => (mark PT.MARKexp (FULL_SPAN, Args AtomicExp))
   | "~" AtomicExp =>
      (mark PT.MARKexp (FULL_SPAN, PT.APPLYexp (PT.IDexp {span={file= !sourcemap, span=FULL_SPAN}, tree=Op.minus}, [PT.LITexp (PT.INTlit 0), AtomicExp])))
   ;

Args
   : args=(AtomicExp*) => (fn f => mkApply(f, args))
   | "()" => (fn f => PT.APPLYexp (f,[]))
   ;

AtomicExp
   : Lit => (mark PT.MARKexp (FULL_SPAN, PT.LITexp Lit))
   | STRING => (mark PT.MARKexp (FULL_SPAN, PT.APPLYexp (PT.IDexp {span={file= !sourcemap, span=FULL_SPAN}, tree=Atom.atom "from-string-lit"},
      [PT.LITexp (PT.STRlit STRING)])))
   | Qid => (mark PT.MARKexp (FULL_SPAN, PT.IDexp Qid))
   (* | path=("." Qid)+ => (foldl (fn (fld,e) => PT.APPLYexp (PT.SELECTexp fld, [e])) AtomicExp path) *)
   | Qid ("." Qid)+ => (foldl (fn (fld,e) => PT.APPLYexp (PT.SELECTexp fld, [e])) (PT.IDexp Qid) SR) 
   | ConUse => (mark PT.MARKexp (FULL_SPAN, PT.CONexp ConUse))
   | "@" "{" Field ("," Field)* "}" =>
      (mark PT.MARKexp (FULL_SPAN, PT.UPDATEexp (Field::SR)))
   | "$" Qid => (mark PT.MARKexp (FULL_SPAN, PT.SELECTexp Qid))
   | "(" Exp ")" ("." Qid)* =>
        (case SR of
           [] => mark PT.MARKexp (FULL_SPAN, Exp)
         | ids => mark PT.MARKexp (FULL_SPAN,
            foldl (fn (fld,e) =>
              PT.APPLYexp (PT.SELECTexp fld, [e])) Exp ids))
   | "{" "}" => (mark PT.MARKexp (FULL_SPAN, PT.RECORDexp []))
   | "{" Name "=" Exp ("," Name "=" Exp)* "}" =>
      (mark PT.MARKexp (FULL_SPAN, PT.RECORDexp ((Name, Exp)::SR)))
   | "let" ValueDecl+ "in" Exp "end" =>
      (mark PT.MARKexp (FULL_SPAN, PT.LETRECexp (ValueDecl, Exp)))
   ;

Field
   : Name "=" Exp => ((Name, SOME Exp))
   | "~" Name => ((Name, NONE))
   ;

ValueDecl
   : "val" Name Name* "=" Exp => (Name1, Name2, Exp)
   | "val" Sym Name* "=" Exp => (Sym, Name, Exp)
   ;

Lit
   : Int => (PT.INTlit Int)
   | "'" "'" => (PT.VEClit "")
   | "'" BITSTR "'" => (PT.VEClit BITSTR)
   ;                   

Int
   : POSINT => (POSINT)
   | HEXINT => (case (HEXINT) of (size,i) => i)
   | NEGINT => (NEGINT)
   ;

Name
   : ID => (ID)
   ;

(* Constructors *)
ConBind
   : CONS => (CONS)
   | "S" => (Atom.atom "S")
   ;

ConUse
   : CONS => ({span={file= !sourcemap, span=FULL_SPAN}, tree=CONS})
   | "S" => ({span={file= !sourcemap, span=FULL_SPAN}, tree=Atom.atom "S"})
   ;

Sym
   : SYMBOL => (SYMBOL)
   | "<" => (Atom.atom "<")
   | ">" => (Atom.atom ">")
   ;

Qid
   : ID => ({span={file= !sourcemap, span=FULL_SPAN}, tree=ID})
   ;
