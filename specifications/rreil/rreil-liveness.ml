# vim:filetype=sml:ts=3:sw=3:expandtab
export select_live: S sem_stmt_list <{live: sem_stmt_list} => {live: sem_stmt_list}>
export liveness: (sem_stmt_list) -> S lv-state-t <{} => {}>
export liveness_super: (translate-result) -> S lv-super-result <{} => {}>
export lv-pretty: (lv-state-t) -> rope

#for optimization-sweep
export liveness_super_chainable: ({insns:sem_stmt_list, succ_a:stmts_option, succ_b:stmts_option}) ->  S {insns:sem_stmt_list, succ_a:stmts_option, succ_b:stmts_option} <{} => {}>

# LIVENESS based on fields

type interval = {lo: int, hi: int}
type id_intervals = {id: sem_id, fields: bbtree[a=interval]}

val visit-semvarls visitor-semvar set varls = case varls of
   SEM_VARLS_CONS c: lv-union (visitor-semvar set c.hd.size c.hd) (visit-semvarls visitor-semvar set c.tl)
 | SEM_VARLS_NIL: set
end

val lv-kill kills stmt =
   let
      val visit-semvar kills sz x = fmap-add-range kills x.id sz x.offset
      val size-lhs size rhs = case rhs of
         SEM_SEXPR s: case s of
            SEM_SEXPR_CMP c: 1
          | _: size
         end
       | _: size
      end

      val visit-stmt kills stmt =
         case stmt of
            SEM_ASSIGN x: visit-semvar kills (size-lhs x.size x.rhs) x.lhs
          | SEM_LOAD x: visit-semvar kills x.size x.lhs
      | SEM_ITE x: lv-union kills (lv-intersection (lv-kills x.then_branch) (lv-kills x.else_branch))
          | SEM_FLOP x: visit-semvar kills x.lhs.size x.lhs
          | SEM_PRIM x: visit-semvarls visit-semvar kills x.lhs
          | _ : kills
         end
   in
      visit-stmt kills stmt
   end

val lv-gen gens stmt = 
   let
      val visit-semvar gens sz x = fmap-add-range gens x.id sz x.offset

      val visit-lin gens sz lin =
         case lin of
            SEM_LIN_VAR x: visit-semvar gens sz x
          | SEM_LIN_IMM x: gens
          | SEM_LIN_ADD x:
               lv-union
                  (visit-lin gens sz x.opnd1)
                  (visit-lin gens sz x.opnd2)
          | SEM_LIN_SUB x:
               lv-union
                  (visit-lin gens sz x.opnd1)
                  (visit-lin gens sz x.opnd2)
          | SEM_LIN_SCALE x: visit-lin gens sz x.opnd
         end

      val visit-sexpr size gens sexpr =
        case sexpr of
           SEM_SEXPR_LIN l: visit-lin gens size l
         | SEM_SEXPR_CMP c: visit-op-cmp size gens c
         | SEM_SEXPR_ARB: gens
        end

      val visit-arity1 gens x = visit-lin gens x.size x.opnd1

      val visit-arity2 size gens x =
         lv-union
            (visit-lin gens size x.opnd1)
            (visit-lin gens size x.opnd2)

        # TODO use size here
      val visit-op-cmp size gens cmp =
        case cmp.cmp of
           SEM_CMPEQ x: visit-arity2 size gens x
         | SEM_CMPNEQ x: visit-arity2 size gens x
         | SEM_CMPLES x: visit-arity2 size gens x
         | SEM_CMPLEU x: visit-arity2 size gens x
         | SEM_CMPLTS x: visit-arity2 size gens x
         | SEM_CMPLTU x: visit-arity2 size gens x
        end

      val visit-expr size gens op =
         case op of
            SEM_SEXPR x: visit-sexpr size gens x
#          | SEM_BSWAP x: visit-arity1 gens x
          | SEM_MUL x: visit-arity2 size gens x
          | SEM_DIV x: visit-arity2 size gens x
          | SEM_DIVS x: visit-arity2 size gens x
          | SEM_MOD x: visit-arity2 size gens x
          | SEM_MODS x: visit-arity2 size gens x
          | SEM_SHL x: visit-arity2 size gens x
          | SEM_SHR x: visit-arity2 size gens x
          | SEM_SHRS x: visit-arity2 size gens x
          | SEM_AND x: visit-arity2 size gens x
          | SEM_OR x: visit-arity2 size gens x
          | SEM_XOR x: visit-arity2 size gens x
          | SEM_SX x: visit-lin gens x.fromsize x.opnd1
          | SEM_ZX x: visit-lin gens x.fromsize x.opnd1
         end

      val visit-address gens x = visit-lin gens x.size x.address

      val visit-flow size gens x =
         lv-union
           (visit-sexpr size gens x.cond)
           (lv-union
             (visit-address gens x.target-true)
             (visit-address gens x.target-false))

      val visit-stmt gens stmt =
         case stmt of
            SEM_ASSIGN x: visit-expr x.size gens x.rhs
          | SEM_LOAD x: visit-address gens x.address
          | SEM_STORE x: lv-union (visit-address gens x.address) (visit-lin gens x.size x.rhs)
       | SEM_WHILE x: visit-sexpr 1 gens x.cond
       | SEM_ITE x: visit-sexpr 1 gens x.cond
       | SEM_BRANCH x: visit-address gens x.target
       | SEM_CBRANCH x: visit-flow 1 gens x
          | SEM_FLOP x: lv-union (visit-semvar gens (sizeof-id x.flags.id) x.flags) (visit-semvarls visit-semvar gens x.rhs)
          | SEM_PRIM x: visit-semvarls visit-semvar gens x.rhs
          | SEM_THROW x: gens
         end
   in
      visit-stmt gens stmt
   end

val lv-gen1 stmt = lv-gen fmap-empty stmt
val lv-kill1 stmt = lv-kill fmap-empty stmt

val lv-gens stmts =
   let
      val visit gens stmts =
         case stmts of
            SEM_CONS x: visit (lv-gen gens x.hd) x.tl
          | _ : gens
         end
   in
      visit fmap-empty stmts
   end

val lv-kills stmts =
   let
      val visit kills stmts =
         case stmts of
            SEM_CONS x: visit (lv-kill kills x.hd) x.tl
          | _ : kills
         end
   in
      visit fmap-empty stmts
   end

val lv-union a b =
   let
      val update m x =
         fmap-update
            m
            {id=x.id,
             fields=
                fitree-union
                  (fmap-get a x).fields
                  (fmap-get b x).fields}
   in
      fmap-fold update (fmap-union a b) (fmap-intersection a b)
   end

val lv-difference a b =
   let
      val update m x =
         fmap-add
            m
            {id=x.id,
             fields=
                fitree-interval-difference
                  (fmap-get a x).fields
                  (fmap-get b x).fields}
   in
      fmap-fold update a (fmap-intersection a b)
   end

val lv-intersection a b = lv-difference ((lv-difference (lv-union a b) (lv-difference a b))) (lv-difference b a)

val lv-any-live? state kill =
   let
      val overlaps? x = 
         let
            val overlaps-interval? l i =
               l or fitree-any-overlapping?
                  (fmap-get-orelse
                     state
                     {id=x.id, fields=fitree-empty}).fields
                  i
         in
            fitree-fold overlaps-interval? '0' x.fields
         end
      val live? l x = l or overlaps? x
   in
      fmap-fold live? '0' kill
   end

val lv-pretty t =
   let
      val fields x = rreil-show-id x.id +++ ":" +++ fitree-pretty x.fields
   in
      bbtree-pretty fields t
   end

val live-stack-backup-and-reset = do
  live <- query $live;
  maybelive <- query $live;
  update @{live=SEM_NIL,maybelive=SEM_NIL};
  return {live=live,maybelive=maybelive}
end

val select_live = query $live

val live-stack-restore backup = update @{live=backup.live,maybelive=backup.maybelive}

val lv-analyze initial-live stack =
   let
      val sweep stack state =
         case stack of
            SEM_NIL: return state
          | SEM_CONS x: let
              val cont kill cont-state =
                 if lv-any-live? state.greedy kill
                    then do 
                          lv-push-live x.hd;
                          sweep x.tl cont-state
                       end
                 else if lv-any-live? state.conservative kill
                    then
                       do lv-push-maybelive x.hd;
                          sweep x.tl cont-state
                       end
                 else sweep x.tl cont-state
            in
              case x.hd of
                 SEM_LOAD y:
                    do lv-push-live x.hd;
                       sweep x.tl (lvstate-eval state x.hd)
                    end
               | SEM_STORE y:
                    do lv-push-live x.hd;
                       sweep x.tl (lvstate-eval state x.hd)
                    end
               | SEM_WHILE y: do
                  backup <- live-stack-backup-and-reset;

                  body-rev <- return (rreil-stmts-rev y.body);
                  body-state <- sweep body-rev (lvstate-empty fmap-empty body-rev);
                  state-new <- return (lvstate-union-conservative state body-state);

                  #maybelive <- query $maybelive;

                  live-stack-restore backup;
                  #lv-push-live (/WHILE y.cond maybelive);
                  lv-push-live (/WHILE y.cond y.body);
                  sweep x.tl (lvstate-eval state-new x.hd)
                 end
               | SEM_ITE y: do
                  org-backup <- live-stack-backup-and-reset;

                  then_branch-rev <- return (rreil-stmts-rev y.then_branch);
                  then-state <- sweep then_branch-rev state;
                  then-backup <- live-stack-backup-and-reset;

                  else_branch-rev <- return (rreil-stmts-rev y.else_branch);
                  else-state <- sweep else_branch-rev state;
                  else-backup <- live-stack-backup-and-reset;

                  live-stack-restore org-backup;

                  #state-new <- let
                  #  val stacks-empty a b = 
                  #    case a of
                  #       SEM_NIL:
                  #        case b of
                  #           SEM_NIL: '1'
                  #         | SEM_CONS x: '0'
                  #        end
                  #     | SEM_CONS x: '0'
                  #   end
                  #in
                  #  if (stacks-empty then-backup.maybelive else-backup.maybelive) == '0' then do
                  #   lv-push-maybelive (/ITE y.cond then-backup.maybelive else-backup.maybelive);
                  #    greedy <-
                  #     if (stacks-empty then-backup.live else-backup.live) == '0' then do
                  #        lv-push-live-only (/ITE y.cond then-backup.live else-backup.live);
                   #        return (lvstate-eval-simple-no-kill state.greedy x.hd)
                  #     end else
                  #       return state.greedy
                  #     ;
                  #   return {greedy=greedy,conservative=lvstate-eval-simple-no-kill state.conservative x.hd}
                  # end else
                  #   return {greedy=state.greedy,conservative=state.conservative}
                  #end;
                  
                  ite-conservative <- return (/ITE y.cond then-backup.maybelive else-backup.maybelive);
                  ite-greedy <- return (/ITE y.cond then-backup.live else-backup.live);
                  lv-push-maybelive ite-conservative;
                  lv-push-live-only ite-greedy;

                  state-new <- return (lvstate-union then-state else-state);

                  #sweep x.tl state-new
                   sweep x.tl (lv-eval-simple state-new x.hd)
                 end
               | SEM_CBRANCH y: do
                   lv-push-live x.hd;
                   sweep x.tl (lvstate-eval state x.hd)
                 end
               | SEM_BRANCH y: do
                   lv-push-live x.hd;
                   sweep x.tl (lvstate-eval state x.hd)
                 end
               | SEM_ASSIGN y: cont (lv-kill1 x.hd) (lvstate-eval state x.hd)
               | SEM_FLOP y: cont (lv-kill1 x.hd) (lvstate-eval state x.hd)
               | SEM_PRIM y: do
                   lv-push-live x.hd;
                   sweep x.tl (lvstate-eval state x.hd)
                 end
               | SEM_THROW y: cont (lv-kill1 x.hd) (lvstate-eval state x.hd)
              end
            end
         end
   in do
#    lv-sweep-and-collect-upto-native-flow;
#     stack <- query $stack;
     update @{live=SEM_NIL,maybelive=SEM_NIL};
     sweep stack (lvstate-empty initial-live stack)
   end end

#val lv-update-state label lvstate =
#   do state <- query $state;
#      update @{state=lmap-update state {lab=label,state=lvstate}}
#   end

val lv-push-maybelive stmt =
   do live <- query $maybelive;
      update @{maybelive=SEM_CONS{hd=stmt,tl=live}}
   end

val lv-push-live-only stmt = do
  live <- query $live;
  update @{live=SEM_CONS{hd=stmt,tl=live}}
end

val lv-push-live stmt = do
  lv-push-live-only stmt;
  lv-push-maybelive stmt
end

## Liveness lattice operations and transfer functions 

val lvstate-union a b =
   {greedy=lv-union a.greedy b.greedy,
    conservative=lv-union a.conservative b.conservative}

val lvstate-union-conservative old conservative-state =
   {greedy=lv-union old.greedy conservative-state.conservative,
    conservative=lv-union old.conservative conservative-state.conservative}

#val lvstate-eval-simple-no-kill state stmt = lv-union state (lv-gen1 stmt)

val lv-eval-simple state stmt =
         {greedy=lv-union state.greedy (lv-gen1 stmt),
          conservative=lv-union state.conservative (lv-gen1 stmt)}

val lvstate-eval state stmt =
   let
      val lvstate-eval-conservative state kill gen =
         lv-union gen (lv-difference state kill)

      val lvstate-eval-greedy state kill gen =
         # HACK: if a statement doesn't kill anything make the {gen} set live
         # alternative: explicitly inspect the visited statement
         if bbtree-empty? kill
            then (lv-union state gen) #Todo: Why gen? ;-)
         else
            lv-union
               (lv-difference state kill)
               (if lv-any-live? state kill
                   then gen
                else fmap-empty)

      val eval kill gen =
         {greedy=lvstate-eval-greedy state.greedy kill gen,
          conservative=lvstate-eval-conservative state.conservative kill gen}
   in
      eval (lv-kill1 stmt) (lv-gen1 stmt)
   end

#val lvstate-eval-ite state ite-greedy ite-conservative =
#   let
#      val lvstate-eval-conservative state kill gen =
#         if bbtree-empty? kill then
#          state
#         else
#           lv-union gen (lv-difference state kill)
#
#      val lvstate-eval-greedy state kill gen =
#         # HACK: if a statement doesn't kill anything make the {gen} set live
#         # alternative: explicitly inspect the visited statement
#         if bbtree-empty? kill then
#          state
#         else
#            lv-union
#               (lv-difference state kill)
#               (if lv-any-live? state kill
#                   then gen
#                else fmap-empty)
#
#      val eval =
#         {greedy=lvstate-eval-greedy state.greedy (lv-kill1 ite-greedy) (lv-gen1 ite-greedy),
#          conservative=lvstate-eval-conservative state.conservative (lv-kill1 ite-conservative) (lv-gen1 ite-conservative)}
#   in
#      eval
#   end

val lvstate-empty initial-live stmts =
   {greedy=initial-live,
    conservative=lv-union (lv-kills stmts) fmap-empty}

#val lvstate-pretty state = lv-pretty state.greedy

## Map labels to (liveness) states

val lmap-lt? a b = a.lab < b.lab
val lmap-value-merge a b = {lab=a.lab, state=lvstate-union a.state b.state}
#val lmap-add t x = bbtree-add lmap-lt? t x
val lmap-add-with f t x = bbtree-add-with lmap-lt? f t x
val lmap-update t x = lmap-add-with lmap-value-merge t x
#val lmap-get-orelse t x = bbtree-get-orelse lmap-lt? t x
#val lmap-union a b = bbtree-union lmap-lt? a b
#val lmap-contains? t x = bbtree-contains? lmap-lt? t x
val lmap-empty = bbtree-empty
#val lmap-size t = bbtree-size t
#val lmap-fold f s t = bbtree-fold f s t
#val lmap-pretty t = 
#   let
#      val pretty kv = "l" +++ showint kv.lab +++ ":" +++ lvstate-pretty kv.state
#   in
#      bbtree-pretty pretty t
#   end


val liveness instructions = do
  lv-state <- lv-analyze registers-live-map (rreil-stmts-rev instructions);
  return lv-state.greedy 
end

type lv-super-result = {initial:lv-state-t, after:lv-state-t}

val liveness_super data = let
  val lv-option-analyze live-registers option =
    case option of
       SO_SOME stmts: do
         state <- lv-analyze live-registers (rreil-stmts-rev stmts);
         return state.greedy
       end
     | SO_NONE: return fmap-empty
    end

  val lv-some-succ live-registers = do
    lv-succ-a <- lv-option-analyze live-registers data.succ_a;
    lv-succ-b <- lv-option-analyze live-registers data.succ_b;
    return (lv-union lv-succ-a lv-succ-b)
  end
in do
  live-registers <- case data.succ_a of
       SO_NONE:
          case data.succ_b of
             SO_NONE: return registers-live-map
           | SO_SOME a: lv-some-succ registers-live-map
          end
     | SO_SOME a: lv-some-succ registers-live-map
    end
  ;
  lv-state <- lv-analyze live-registers (rreil-stmts-rev data.insns);
  return {initial=live-registers, after=lv-state.greedy}
end end

val liveness_super_chainable data = do
  liveness_super data;
  live <- query $live;
  return {insns=live, succ_a=data.succ_a, succ_b=data.succ_b}
end

type lv-state-t = bbtree[a=id_intervals]
