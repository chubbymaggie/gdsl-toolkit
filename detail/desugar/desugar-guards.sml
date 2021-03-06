
structure DesugarGuards : sig
   type value = SplitDeclarations.value
   type pat = SplitDeclarations.pat
   type exp = SplitDeclarations.exp
   type decode = pat list * exp
   type o = (value list * decode list SymMap.map) Spec.t
   val run: SplitDeclarations.o -> o CompilationMonad.t
   val layout: decode list SymMap.map -> Layout.layout
end = struct
   structure CM = CompilationMonad
   structure AST = SpecAbstractTree
   structure Map = SymMap
   
   type value = SplitDeclarations.value
   type pat = SplitDeclarations.pat
   type exp = SplitDeclarations.exp
   type decode = pat list * exp
   type o = (value list * decode list SymMap.map) Spec.t

   val bool = Atom.atom "g"
   val raisee = Atom.atom "raise"
   val query = Atom.atom "query"

   fun bind (map, n, d) =
      Map.unionWith op@ (map, Map.singleton (n, d))

   fun freshBool () = let
      val (tab, sym) =
         VarInfo.fresh (!SymbolTables.varTable, bool)
   in
      sym before SymbolTables.varTable := tab
   end

   fun raisingUnsatisfiableGuardComb sp = let
      open AST
      val raisee = VarInfo.lookup (!SymbolTables.varTable, raisee)
   in
      APPLYexp
         (IDexp raisee,
          [LITexp
            (STRlit ("unsatisfiable guards at " ^ Error.spanToString sp))])
   end

   fun iff (guard, thenn, elsee) = let
      open AST
      val cond = freshBool ()
      val query = VarInfo.lookup (!SymbolTables.varTable, query)
   in
      SEQexp
         [BINDseqexp (cond, APPLYexp (IDexp query, [guard])),
          ACTIONseqexp
            (IFexp
               (IDexp cond,
                thenn,
                elsee))]
   end

   fun getPatPos (AST.MARKdecodepat t :: _) = #span t
     | getPatPos _ = SymbolTable.noSpan
   fun getGuardPos (AST.MARKexp t) = #span t
     | getGuardPos _ = SymbolTable.noSpan
     
   fun desugarGuards ds = Map.foldli desugars Map.empty ds
   
   and desugars (n, ds, map) = bind (map, n, List.map desugar ds)

   and desugar d =
      case d of
         (pat, Sum.INL e) => (pat, e)
       | (pat, Sum.INR es) => (pat, flatten (getPatPos pat, es))

   and flatten (sp, es) = let
      fun lp (sp, es) =
         case es of
            [] => raisingUnsatisfiableGuardComb sp
          | (g, thenn)::ges => iff (g, thenn, lp (getGuardPos g, ges))
   in
     lp (sp, es) 
   end

   fun dumpPre (os, spec) = let
      open Layout Pretty
      fun layout n (pats, e) =
         AST.PP.decl
            (AST.DECODEdecl (n, pats, e))
      fun layouts (n, ds, acc) = map (layout n) ds @ acc
      val doc = align (Map.foldli layouts [] spec)
   in
      Pretty.prettyTo (os, doc)
   end

   fun layout spec = let
      open Layout Pretty
      fun layout n (pats, e) =
         AST.PP.decl
            (AST.DECODEdecl (n, pats, Sum.INL e))
      fun layouts (n, ds, acc) = map (layout n) ds @ acc
   in
      align (Map.foldli layouts [] spec)
   end

   fun dumpPost (os, spec) = Pretty.prettyTo (os, layout spec)

   val desugarGuards =
      BasicControl.mkKeepPass
         {passName="desugarGuards",
          registry=DesugarControl.registry,
          pass=desugarGuards,
          preExt="ast",
          preOutput=dumpPre,
          postExt="ast",
          postOutput=dumpPost}

   fun run spec = 
      CM.return
         (Spec.upd
            (fn (vs, ds) =>
               (vs, desugarGuards ds)) spec)
end
