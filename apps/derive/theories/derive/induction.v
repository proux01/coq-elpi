(* Generates the induction principle.

   license: GNU Lesser General Public License Version 2.1 or later           
   ------------------------------------------------------------------------- *)

From elpi Require Export elpi. From elpi.apps Require Export  derive.param1 derive.param1_functor.

Elpi Db derive.induction.db lp:{{

type induction-db inductive -> term -> prop.

:name "induction-db:fail"
induction-db T _ :-
  M is "derive.induction: can't find the induction principle for " ^ {std.any->string T},
  stop M.

}}.

Elpi Command derive.induction.

Elpi Accumulate File "paramX-lib.elpi" From elpi.apps.derive.
Elpi Accumulate File "param1.elpi" From elpi.apps.derive.
Elpi Accumulate Db derive.param1.db.

Elpi Accumulate Db derive.param1.functor.db.

Elpi Accumulate Db derive.induction.db.
Elpi Accumulate File "induction.elpi" From elpi.apps.derive.
Elpi Accumulate lp:{{
  main [str I, str O] :- !, coq.locate I (indt GR), derive.induction.main GR O _.
  main [str I] :- !,
    coq.locate I (indt GR), Name is {coq.gref->id (indt GR)} ^ "_induction",
    derive.induction.main GR Name _.
  main _ :- usage.

  usage :-
    coq.error "Usage: derive.induction <inductive type name> [<output name>]".
}}.  
Elpi Typecheck.

