
structure ImpFromCore : sig
   val run:
      Core.Spec.t ->
         Imp.Spec.t CompilationMonad.t

end = struct

   structure CM = CompilationMonad

   exception ImpTranslationBug

   open Core
   open Imp
   
   val constructors: (Spec.sym * Spec.ty option) SymMap.map ref = ref SymMap.empty

   fun freeVars (Exp.LETVAL (s,b,e)) =
      SymSet.union (freeVars b,
         SymSet.difference (freeVars e, SymSet.singleton s))
     | freeVars (Exp.LETREC (ds,e)) =
      foldl (fn ((f, args, body), ss) =>
            SymSet.union (ss,
               SymSet.difference (
                  freeVars body,
                  SymSet.addList (SymSet.singleton f, args)
               )
            )) (freeVars e) ds
     | freeVars (Exp.IF (c,e,t)) =
      SymSet.union (freeVars c, SymSet.union (freeVars e, freeVars t))
     | freeVars (Exp.CASE (e, cases)) =
      let
         fun freeInCase (Pat.CON (c, SOME a), e) =
            SymSet.difference (freeVars e, SymSet.fromList [a,c])
           | freeInCase (Pat.CON (c, NONE), e) =
            SymSet.difference (freeVars e, SymSet.singleton c)
           | freeInCase (Pat.ID s, e) =
            SymSet.difference (freeVars e, SymSet.singleton s)
           | freeInCase (_, e) = freeVars e
      in
         foldl (fn (c, ss) => SymSet.union (freeInCase c, ss)) (freeVars e) cases
      end
     | freeVars (Exp.APP (e,args)) =
      foldl (fn (arg,ss) => SymSet.union (freeVars arg, ss)) (freeVars e) args
     | freeVars (Exp.PRI (_,args)) = SymSet.addList (SymSet.empty, args)
     | freeVars (Exp.FN (s,e)) =
      SymSet.difference (freeVars e, SymSet.singleton s)
     | freeVars (Exp.SEQ seq) =
      let
         fun gather (Exp.ACTION t :: rem) =
               SymSet.union (freeVars t, gather rem)
           | gather (Exp.BIND (s,t) :: rem) =
               SymSet.union (freeVars t,
                  SymSet.difference (gather rem, SymSet.singleton s))
           | gather [] = SymSet.empty
      in
         gather seq
      end
     | freeVars (Exp.ID s) = SymSet.singleton s
     | freeVars _ = SymSet.empty


   fun addLocalVar { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } sym =
      let
         val _ = ds := SymSet.add (!ds, sym)
      in
         { functionSyms = funcs, localVars = SymSet.add (lv,sym), resVar = res, declVars = ds, constants = cs }
      end
   fun freshRes (str,{ functionSyms = funcs, localVars = lv, declVars = ds, resVar = _, constants = cs }) =
      let
         val tab = !SymbolTables.varTable
         val (tab, res) = SymbolTable.fresh (tab, Atom.atom (str ^ "Res"))
         val _ = SymbolTables.varTable := tab
         val _ = ds := SymSet.add (!ds, res)
       in
         (res,{ functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs })
      end
   
   fun addFunction { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } (sym,ty) =
         funcs := SymMap.insert (!funcs,sym,ty)
   fun getFunction { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } sym =
         SymMap.find (!funcs,sym)

   (* functions operating on the mutable variables *)
   fun addDecl { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } decl =
      let
         val { functions = fs, fields, prim_map } = cs
      in
         fs := decl :: !fs
      end
   fun addField { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } sym =
      let
         val { functions, fields = fs, prim_map } = cs
      in
         fs := SymMap.insert (!fs,sym,OBJvtype)
      end
   fun addUpdate s (fields, fType) =
      let
         val ftab = !SymbolTables.fieldTable
         val name = Atom.atom (foldl
                     (fn (sym, str) =>
                        str ^ "_" ^ SymbolTable.getInternalString (ftab,sym))
                     "update" fields)
         val tab = !SymbolTables.varTable
      in
         case SymbolTable.find (tab, name) of
            NONE =>
               let
                  val (tab, sym) = SymbolTable.fresh (tab, name)
                  val _ = addDecl s 
                           (UPDATEdecl { updateName = sym, 
                                         updateFields = fields,
                                         updateType = fType })
                  val _ = app (addField s) fields
                  val _ = addFunction s (sym, fType)
                  val _ = SymbolTables.varTable := tab
               in
                  sym
               end
          | SOME sym => sym
      end
   fun addSelect s (field, fType) =
      let
         val ftab = !SymbolTables.fieldTable
         val name = Atom.atom ("select_" ^ 
                               SymbolTable.getInternalString (ftab,field))
         val tab = !SymbolTables.varTable
      in
         case SymbolTable.find (tab, name) of
            NONE =>
               let
                  val (tab, sym) = SymbolTable.fresh (tab, name)
                  val _ = SymbolTables.varTable := tab                        
                  val _ = addDecl s 
                           (SELECTdecl { selectName = sym,
                                         selectField = field,
                                         selectType = fType })
                  val _ = addField s field
                  val _ = addFunction s (sym,fType)
               in
                  sym
               end
          | SOME sym => sym
      end
   fun addConFun s (con, fType) =
      let
         val ctab = !SymbolTables.conTable
         val conName = SymbolTable.getInternalString (ctab,con)
         val name = Atom.atom ("constructor_" ^ conName)
         val tab = !SymbolTables.varTable
      in
         case SymbolTable.find (tab, name) of
            NONE =>
               let
                  val arg = Atom.atom ("arg_of_" ^ conName) 
                  val (tab, sym) = SymbolTable.fresh (tab, name)
                  val (tab, sym') = SymbolTable.fresh (tab, arg)
                  val _ = SymbolTables.varTable := tab                        
                  val _ = addDecl s (CONdecl { conName = sym,
                                               conArg = sym',
                                               conType = fType })
                  val _ = addFunction s (sym,fType)
               in
                  sym
               end
          | SOME sym => sym
      end
   
   fun get_con_idx e = PRIexp (PUREmonkind, GET_CON_IDXprim,
      FUNvtype (INTvtype, false, [OBJvtype]), [e])
   fun get_con_arg e = PRIexp (PUREmonkind, GET_CON_ARGprim,
      FUNvtype (OBJvtype, false, [OBJvtype]), [e])

   fun trBlock { functionSyms = funcs, localVars = lv, declVars = ds, resVar = res, constants = cs } e =
      let
         (* add the result variable to this scope if it is not already defined in the previous scope,
            this is a quick fix for functions that declare their result value within the scope
            of this function *)
         val initSet = if SymSet.member (!ds,res) then SymSet.empty else SymSet.singleton res
         val localDs = ref initSet
         val sLocal = { functionSyms = funcs, localVars = lv, declVars = localDs, resVar = res, constants = cs }
         val (stmts, exp) = trExpr sLocal e
         val decls = map (fn s => (OBJvtype, s)) (SymSet.listItems (!localDs))
      in
         BASICblock (decls, stmts @ [ASSIGNstmt (SOME res, exp)])
      end
   and trExpr s (Exp.LETVAL (x,b,e)) =
      let
         val (bStmts, bExp) = trExpr (addLocalVar s x) b
         val (eStmts, eExp) = trExpr s e
      in
         (bStmts @ ASSIGNstmt (SOME x,bExp) :: eStmts, eExp)
      end
     | trExpr s (Exp.LETREC (ds, e)) =
      let
         val _ = app (fn (sym,args,_) =>
            addFunction s (sym,FUNvtype (OBJvtype,false,map (fn _ => OBJvtype) args))) ds
         val _ = List.map (trDecl s) ds
      in
         trExpr s e
      end
     | trExpr s (Exp.IF (c,t,e)) =
      let
         val (cStmts, cExp) = trExpr s c
         val (res,s) = freshRes ("ite",s)
         val tBlock = trBlock s t
         val eBlock = trBlock s e
      in
         (cStmts @ [IFstmt (VEC2INTexp (SOME 1,UNBOXexp (BITvtype,cExp)), tBlock, eBlock)], IDexp res)
      end
     | trExpr s (Exp.CASE (e, cs)) =
      let
         (* extract the scrutinee as an int which requires different
            primitives, depending on the type that is matched *)
         fun convertScrut (e, (Core.Pat.BIT bp,_) :: cs) =
            let
               val fields = String.fields (fn c => c= #"|") bp
            in
               case fields of
                  [] => convertScrut (e, cs)
                | (f::_) => VEC2INTexp (SOME (String.size f),UNBOXexp (BITvtype,e))
            end
           | convertScrut (e, (Core.Pat.INT _,_) :: _) = UNBOXexp (INTvtype,e)
           | convertScrut (e, (Core.Pat.CON (sym,_),_) :: _) = get_con_idx e
           | convertScrut (e, _ :: cs) = convertScrut (e, cs)
           | convertScrut _ = raise ImpTranslationBug
         val (stmts, scrutRaw) = trExpr s e
         val scrut = convertScrut (scrutRaw, cs)
         
         val (res,s) = freshRes ("case",s)
         fun trCase (Core.Pat.BIT bp, block) = (
               case String.fields (fn c => c= #"|") bp of
                  [] => (WILDpat, block)
                | fs => (VECpat fs, block)
             )
           | trCase (Core.Pat.INT i, block) = (INTpat i, block)
           | trCase (Core.Pat.CON (sym,NONE), block) = (CONpat sym, block)
           | trCase (Core.Pat.CON (sym,SOME arg), BASICblock (decls, stmts)) =
               (CONpat sym, BASICblock (decls, ASSIGNstmt (SOME sym,get_con_arg scrutRaw) :: stmts))
           | trCase (Core.Pat.ID sym, BASICblock (decls, stmts)) =
               (WILDpat, BASICblock (decls, ASSIGNstmt (SOME sym,scrutRaw) :: stmts))
           | trCase (Core.Pat.WILD, block) = (WILDpat, block)

         val cases = map (fn (pat,e) => trCase (pat,trBlock s e)) cs
      in
         (stmts @ [CASEstmt (scrut, cases)], IDexp res)
      end
     | trExpr s (Exp.APP (func, args)) =
      let
         val (stmts, funcExp) = trExpr s func
         val (stmtss, argExps) = foldl (fn (arg, (stmtss, args)) =>
            case trExpr s arg of (stmts, argExp) =>
            (stmtss @ stmts, args @ [argExp])) ([],[]) args
         val ty = FUNvtype (OBJvtype,false,map (fn _ => OBJvtype) args)
      in
         (stmtss, INVOKEexp (PUREmonkind, ty, funcExp, argExps))
      end
     | trExpr s (Exp.PRI (name, args)) = (
         (* this case is actually dead as all primitives are function calls,
            they are replaced by proper primitives during optimization *)
         case SymMap.find (#prim_map (#constants s), name) of
            SOME (_, gen) => ([], gen (map IDexp args))
          | NONE => raise ImpTranslationBug)
     | trExpr s (Exp.FN (var, e)) =
      let
         val tab = !SymbolTables.varTable
         val (tab, sym) = SymbolTable.fresh (tab, Atom.atom "lambda")
         val _ = SymbolTables.varTable := tab
         val fType = trDecl (addLocalVar s var) (sym, [var], e)
      in
         ([], CLOSUREexp (fType, sym, [IDexp var]))
      end
     | trExpr s (Exp.RECORD fs) =
      let
         fun trans acc res [] = (acc,res)
           | trans acc res ((f,e) :: es) = (case trExpr s e of
              (stmts, e') => trans (acc @ stmts) (res @ [(f,e')]) es)
         val (stmts, unsortedFields) = trans [] [] fs
         fun fieldCmp ((f1,_),(f2,_)) = SymbolTable.compare_symid (f1,f2)
         val fields = ListMergeSort.uniqueSort fieldCmp unsortedFields
         val _ = app (fn (f,e) => addField s f) fs
      in
         (stmts, RECORDexp fields)
      end
     | trExpr s (Exp.UPDATE us) =
      let
         (* evaluate expressions in the sequence as they were specified
            by and then generate an update function with sorted arguments *)
         fun trans acc res [] = (acc,res)
           | trans acc res ((f,e) :: es) = (case trExpr s e of
              (stmts, e') => trans (acc @ stmts) (res @ [(f,e')]) es)
         val (stmts, unsortedUpdates) = trans [] [] us
         fun updateCmp ((f1,_),(f2,_)) = SymbolTable.compare_symid (f1,f2)
         val updates = ListMergeSort.uniqueSort updateCmp unsortedUpdates
         val resTy = FUNvtype (OBJvtype, true, [OBJvtype])
         val fType = FUNvtype (resTy, false, map (fn _ => OBJvtype) updates)
         val updateFun = addUpdate s (map (fn (f,_) => f) updates, fType)
      in
         (stmts, CLOSUREexp (resTy, updateFun, map (fn (_,e) => e) updates))
      end
     | trExpr s (Exp.SELECT f) =
      let
         val fType = FUNvtype (OBJvtype, false, [OBJvtype])
         val selectFun = addSelect s (f, fType)
      in
         ([], CLOSUREexp (fType, selectFun, []))
      end
     | trExpr s (Exp.SEQ seq) =
      let
         fun transSeq s acc [Exp.ACTION e] =
               let
                  val (stmts, exp) = trExpr s e
               in
                  (acc @ stmts, exp)
               end
           | transSeq s acc ((Exp.ACTION e) :: seq) =
               let
                  val (stmts, exp) = trExpr s e
                  val stmtss = acc @ stmts @ [ASSIGNstmt (NONE,(EXECexp exp))]
               in
                  transSeq s stmtss seq
               end
           | transSeq s acc ((Exp.BIND (res,e)) :: seq) =
               let
                  val (stmts, exp) = trExpr s e
                  val stmtss = acc @ stmts @ [ASSIGNstmt (SOME res,(EXECexp exp))]
               in
                  transSeq (addLocalVar s res) stmtss seq
               end
           | transSeq s acc _ = raise ImpTranslationBug
      in
         transSeq s [] seq
      end
     | trExpr s (Exp.LIT (SpecAbstractTree.INTlit i)) =
         ([], BOXexp (INTvtype, LITexp (INTvtype, INTlit i)))
     | trExpr s (Exp.LIT (SpecAbstractTree.STRlit str)) =
         ([], LITexp (STRINGvtype,STRlit str))
     | trExpr s (Exp.LIT (SpecAbstractTree.VEClit v)) =
         ([], BOXexp (BITvtype, INT2VECexp (String.size v, LITexp (INTvtype, (VEClit v)))))
     | trExpr s (Exp.LIT (SpecAbstractTree.FLTlit _)) =
         raise ImpTranslationBug
     | trExpr s (Exp.CON sym) =
      (case SymMap.lookup (!constructors, sym) of
         (_, NONE) => ([], BOXexp (INTvtype, LITexp (INTvtype, CONlit sym)))
       | (_, SOME _) =>
         let
            val fType = FUNvtype (OBJvtype,false,[OBJvtype])
         in
            ([], CLOSUREexp (fType, addConFun s (sym, fType), []))
         end
       )
     | trExpr s (Exp.ID sym) =
      ([], case getFunction s sym of
         NONE => IDexp sym
       | SOME ty => CLOSUREexp (ty, sym, [])
      )

   and trDecl s (sym, args, body) =
      let
         val (res,s) = freshRes (SymbolTable.getInternalString(!SymbolTables.varTable,sym),s)
         val block = trBlock s body
         val availInClosure = SymSet.singleton sym
         val availInClosure =
            SymSet.addList (availInClosure, SymMap.listKeys (!(#functionSyms s)))
         val availInClosure =
            SymSet.addList (availInClosure,  args)
         val inClosure = SymSet.difference (freeVars body, availInClosure)
         fun setToArgs ss = map (fn s => (OBJvtype, s)) (SymSet.listItems ss)
         val clArgs = setToArgs inClosure
         val stdArgs = map (fn s => (OBJvtype, s)) args
         val fType = FUNvtype (OBJvtype, not (null clArgs), map (fn (t,_) => t) stdArgs)
         val _ =
            addDecl s (FUNCdecl {
              funcMonadic = PUREmonkind,
              funcClosure = clArgs,
              funcType = fType,
              funcName = sym,
              funcArgs = map (fn s => (OBJvtype, s)) args,
              funcBody = block,
              funcRes = res
            })
      in
         fType
      end

   fun translate spec =
      Spec.upd
         (fn clauses =>
            let
               val () = constructors := Spec.get#constructors spec
               fun exports clauses =
                  rev (foldl
                     (fn ((f, _, _), acc) => 
                        let
                           val fld =  f
                        in
                           (fld, Exp.ID f)::acc
                        end)
                     [] clauses)
               fun exports spec =
                  let 
                     val es = Spec.get#exports spec
                  in
                     map (fn e => (Exp.ID e)) es
                  end
               val fs = ref ([] : decl list)
               val fields = ref (SymMap.empty : vtype SymMap.map)
               
               val globs = SymMap.map (fn (ty,gen) => ty) (!Primitives.prim_map)
               val cs = { functions = fs,
                          prim_map = !Primitives.prim_map,
                          fields = fields }
                          
               val initialState = { functionSyms = ref globs,
                                    localVars = SymSet.empty,
                                    declVars = ref SymSet.empty,
                                    resVar = SymbolTable.unsafeFromInt ~1,
                                    constants = cs
                                   }
               val bogusExp = Exp.LIT (SpecAbstractTree.INTlit 42)
               val _ = trExpr initialState (Exp.LETREC (clauses, bogusExp))
            in
               { decls = !(#functions cs),
                 fdecls = !(#fields cs) }
            end) spec

   fun dumpPre (os, spec) = Pretty.prettyTo (os, Core.PP.spec spec)
   fun dumpPost (os, spec) = Pretty.prettyTo (os, Imp.PP.spec spec)
 
   val translate =
      BasicControl.mkKeepPass
         {passName="impConversion",
          registry=CPSControl.registry,
          pass=translate,
          preExt="core",
          preOutput=dumpPre,
          postExt="imp",
          postOutput=dumpPost}

   fun run spec = CM.return (translate spec)
end
