structure PatchFunctionCallsPass = MkIMPPass (PatchFunctionCalls)
structure ActionReducePass = MkIMPPass (ActionReduce)
structure ActionClosuresPass = MkIMPPass (ActionClosures)
structure SimplifyPass = MkIMPPass (Simplify)
structure TypeRefinementPass = MkIMPPass (TypeRefinement)
structure SwitchReducePass = MkIMPPass (SwitchReduce)
structure DeadFunctionsPass = MkIMPPass (DeadFunctions)
structure DeadVariablesPass = MkIMPPass (DeadVariables)
structure UnboxConstructorPayloadPass = MkIMPPass (UnboxConstructorPayload)

structure ImpPasses : sig
   val run:
      Core.Spec.t ->
         Imp.Spec.t CompilationMonad.t
end = struct

   structure CM = CompilationMonad

   open CM
   infix >>=

   fun all s =
      ImpFromCore.run s >>=
      SimplifyPass.run >>=
      PatchFunctionCallsPass.run >>=
      SimplifyPass.run >>=
      ActionReducePass.run >>=
      ActionReducePass.run >>=
      SimplifyPass.run >>=
      ActionClosuresPass.run >>=
      SimplifyPass.run >>=
      UnboxConstructorPayloadPass.run >>=
      TypeRefinementPass.run >>=
      SimplifyPass.run >>=
      SwitchReducePass.run >>=
      SimplifyPass.run >>=
      DeadFunctionsPass.run >>=
      DeadVariablesPass.run >>=
      SimplifyPass.run


   fun dumpPre (os, (_, spec)) = Pretty.prettyTo (os, Core.PP.spec spec)
   fun dumpPost (os, spec) = Pretty.prettyTo (os, Imp.PP.spec spec)
   fun pass (s, spec) = CM.run s (all spec)

   val passes =
      BasicControl.mkKeepPass
         {passName="imp",
          registry=ImpControl.registry,
          pass=pass,
          preExt="ast",
          preOutput=dumpPre,
          postExt="imp",
          postOutput=dumpPost}

   fun run spec =
      getState >>= (fn s =>
      return (passes (s, spec)))
end
