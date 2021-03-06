
structure DesugarDecode = struct
   structure VS = VectorSlice
   structure CM = CompilationMonad
   structure DT = DesugaredTree
   structure Set = IntBinarySet
   structure Pat = DesugaredTree.Pat

   open DT 

   fun insert (map, k, i) = let
      val s =
         case StringMap.find (map, k) of
            NONE => Set.singleton i
          | SOME s => Set.add (s, i)
   in
      StringMap.insert (map, k, s)
   end

   val tok = Atom.atom "tok"
   val return = Atom.atom "return"
   val raisee = Atom.atom "raise"

   fun raisingDecodeSequenceMatchFailure () = let
      open Exp
      val raisee = ID (VarInfo.lookup (!SymbolTables.varTable, raisee))
   in
      APP (raisee, [LIT (SpecAbstractTree.STRlit "DecodeSequenceMatchFailure")])
   end

   fun freshTok () = let
      val (tab, sym) =
         VarInfo.fresh (!SymbolTables.varTable, tok)
   in
      sym before SymbolTables.varTable := tab
   end

   fun consumeTok (granularity) = let
      val _ = if granularity mod 8 = 0 then granularity else
              (TextIO.print ("cannot consume " ^ Int.toString granularity ^ " bits.\n"); 8)
      val tok = freshTok ()
      val tokSz = Int.toString(granularity)
      val consume = Atom.atom("consume"^tokSz)
      val consume =
         Exp.ID
            (VarInfo.lookup
               (!SymbolTables.varTable, consume))
   in
      (tok, Exp.BIND (tok, consume))
   end

   fun unconsumeTok (granularity) = let
      val tokSz = Int.toString(granularity)
      val unconsume = Atom.atom("unconsume"^tokSz)
      val unconsume =
         Exp.ID
            (VarInfo.lookup
               (!SymbolTables.varTable, unconsume))
   in
      Exp.ACTION unconsume
   end

   fun returnExp e = let
      open Exp
      val return =
         ID
            (VarInfo.lookup
               (!SymbolTables.varTable, return))
   in
      APP (return, [e]) 
   end

   fun buildEquivClass decls = let
      fun getSpan toks = if VS.length toks = 0 then SymbolTable.noSpan else
         case VS.sub (toks, 0) of
            (Pat.VEC (sp,_)::_) => sp
          | (Pat.BND (sp,_,_)::_) => sp
          | _ => SymbolTable.noSpan
        
      fun buildEquiv (i, (toks, _, _), map) =
         StringMap.unionWith (fn ((sp1,rules1),(sp2,rules2)) => (sp1,Set.union (rules1,rules2)))
            (map, StringMap.singleton (
             if VS.length toks = 0
               then "" (* as placeholder for the real wildcard pattern "_" *)
             else toWildcardPattern (VS.sub (toks, 0)),
             (getSpan toks, Set.singleton i))
            )
   in
      VS.foldli buildEquiv StringMap.empty decls
   end

   fun isBacktrackPattern p = String.size p = 0

   fun layoutDecls (decls: (Pat.t list VS.slice * toksize * Exp.t) VS.slice) = let
      open Layout Pretty
      fun pats ps = vector (VS.map (fn ps => list (map DT.PP.pat ps)) ps)
   in
      align
         [str "decls:", 
          vector (VS.map
            (fn pse =>
               tuple3 (pats, str o Int.toString, DT.PP.exp) pse) decls),
          str " "]
   end

   fun getGranularity (decls: (Pat.t list VS.slice * toksize * Exp.t) VS.slice) =
         if VS.length decls = 0 
            then raise Fail "empty pattern detected"
            else #2 (VS.sub (decls, 0))

   fun desugar ds = let
      fun isCatchAll [] = true
        | isCatchAll ([Pat.VEC (_, str)] :: _) =
            List.all (fn c => c= #".") (String.explode str)
        | isCatchAll ([Pat.BND (_, _,str)] :: _) =
            List.all (fn c => c= #".") (String.explode str)
        | isCatchAll _ = false

      fun lp (hasDefault, size, ds, acc) =
         case ds of
            [] => if hasDefault then rev acc else
                     rev ((toVec [], size, raisingDecodeSequenceMatchFailure ()) :: acc)
          | (toks, size, e)::ds => lp (hasDefault orelse isCatchAll toks,
                                 size, ds, (toVec toks, size, e)::acc)
   in
      desugarCases (toVec (lp (false, 0, ds, [])))
   end

   and desugarCases (decls: (Pat.t list VS.slice * toksize * Exp.t) VS.slice) = let
      fun grabExp () = 
         if VS.length decls = 0 
            then raise Fail "empty pattern detected"
         else if VS.length decls > 1 
            then raise Fail ("overlapping pattern detected for " ^
               VS.foldl (fn ((pats,_,e),str) => 
                  VS.foldl (fn (pl,str) => Layout.tostring (DesugaredTree.PP.tokpat pl) ^ str) "" pats ^
                  " => " ^ Layout.tostring (Core.PP.layout e) ^ "\n" ^ str) "" decls
               )
         else #3 (VS.sub (decls, 0))
      fun isEmpty (vs, _, _) = VS.length vs = 0
      val bottom = VS.all isEmpty decls
   in
      if bottom
         then grabExp ()
      else
         let
            val (tok, bindTok) = consumeTok (getGranularity decls)
         in
            Exp.SEQ
               [bindTok,
                Exp.ACTION
                  (Exp.CASE
                     (Exp.ID tok, desugarMatches tok decls))]
         end
   end

   and desugarMatches tok decls = let
      (* +DEBUG:overlapping-patterns *)
       (*val () = Pretty.prettyTo (TextIO.stdOut, layoutDecls decls) *)
      val equiv = buildEquivClass decls
      (* +DEBUG:overlapping-patterns *)
       (*val () =
         Pretty.prettyTo
            (TextIO.stdOut,
             Pretty.stringtab Pretty.intset equiv) *)
      
      fun genBindSlices indices = let
         open DT.Pat
         fun grabSlices (i, acc) = let
            val (toks, granularity, e) = VS.sub (decls, i)
            fun grab (pats, offs, acc) =
               case pats of
                  [] => acc
                | pat::ps =>
                     case pat of
                        VEC _ => grab (ps, offs + size pat, acc)
                      | BND (_, n, _) =>
                           let
                              val sz = size pat
                           in
                              if offs = 0 andalso sz = granularity
                                 then
                                    grab (ps, offs + sz,
                                       Exp.BIND (n, returnExp (Exp.ID tok))::acc)
                              else
                                 grab
                                    (ps,
                                     offs + sz,
                                     Exp.BIND
                                       (n,
                                        returnExp (DT.sliceExp (tok, offs, sz)))::acc)
                           end
         in
            if VS.length toks = 0
               then acc
            else grab (rev (VS.sub (toks, 0)), 0, acc)
         end
      in
         rev (Set.foldl grabSlices [] indices)
      end

      fun backtrack () =
         case StringMap.find (equiv, "") of
            NONE => raise Fail "desugarCases.bug.unboundedBacktrackPattern"
          | SOME (sp,ix) =>
               (case Set.listItems ix of
                  [i] => 
                     let
                        val (_,granularity,e) = VS.sub (decls,i)
                     in
                        Exp.SEQ [unconsumeTok granularity,Exp.ACTION e]
                     end
                | is => (Pretty.prettyTo (TextIO.stdOut, layoutDecls (toVec (map (fn i => VS.sub (decls,i)) is)));
                         raise Fail "desugarCases.bug.overlappingBacktrackPattern"))

      fun extendBacktrackPath ds =
         case StringMap.find (equiv, "") of
            NONE => ds
          | SOME (sp,ix) =>
               (case Set.listItems ix of
                  [i] => 
                     let
                        val (tok,granularity,e) = VS.sub (decls,i)
                     in
                        (tok, granularity, Exp.SEQ [unconsumeTok granularity, Exp.ACTION e])::ds
                     end
                | _ => raise Fail "desugarCases.bug.overlappingBacktrackPattern")

      fun isFullWildcard toks =
         let
            val tok = VS.sub(toks,0)
         in
            CharVector.all (fn c => c = #".") (toWildcardPattern tok)
         end

      fun stepDown indices = let
         fun nextIdx (i, acc) = let
            val (toks, granularity, e) = VS.sub (decls, i)
         in
            if VS.length toks = 0
               then (toVec [], granularity, e)::acc
            else (VS.subslice (toks, 1, NONE), granularity, e)::acc
         end
         val decls = Set.foldl nextIdx [] indices
         val decls = 
            case decls of
               [(toks,_,e)] =>
                  if VS.length toks = 0 orelse isFullWildcard toks
                     then decls
                  else extendBacktrackPath decls
             | _ => extendBacktrackPath decls
         val decls = toVec (rev decls)
         val slices = genBindSlices indices
      in
         if null slices
            then desugarCases decls
         else Exp.SEQ (slices @ [Exp.ACTION (desugarCases decls)])
      end

      fun buildMatch (pat, (sp, indices), pats) =
         if isBacktrackPattern pat
            then (sp, Core.Pat.BIT pat, backtrack())::pats
         else (sp, Core.Pat.BIT pat, stepDown indices)::pats
   in
      StringMap.foldli buildMatch [] equiv
   end
end

structure DesugarDecodeSyntax : sig
   val run:
      DesugaredTree.spec ->
         Core.Spec.t CompilationMonad.t
end = struct

   structure CM = CompilationMonad
   structure DT = DesugaredTree

   fun desugar ds =
      List.map
         (fn (n, ds) => (n, [], DesugarDecode.desugar ds))
         (SymMap.listItemsi ds)

   fun dumpPre (os, spec) = Pretty.prettyTo (os, DT.PP.spec spec)
   fun dumpPost (os, spec) = Pretty.prettyTo (os, Core.PP.spec spec)

   fun pass t =
      Spec.upd
         (fn (vs, ds) =>
            let
               val vss = desugar ds
            in
               vs@vss
            end) t
      
   val pass =
      BasicControl.mkKeepPass
         {passName="desugarDecodeSyntax",
          registry=DesugarControl.registry,
          pass=pass,
          preExt="ast",
          preOutput=dumpPre,
          postExt="ast",
          postOutput=dumpPost}

   fun run spec = CM.return (pass spec)
end
