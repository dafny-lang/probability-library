/*******************************************************************************
 *  Copyright by the contributors to the Dafny Project
 *  SPDX-License-Identifier: MIT
 *******************************************************************************/

module DiscreteLaplace.Equivalence {
  import Rand
  import Monad
  import Rationals
  import BernoulliExpNeg
  import Uniform
  import Coin
  import Model
  import Loops

  /************
   Definitions
  ************/

  ghost opaque function SampleInnerLoopTailRecursive(x: (bool, int) := (true, 0)): Monad.Hurd<(bool, int)> {
    assume {:axiom} false; // assume termination
    (s: Rand.Bitstream) =>
      if x.0 then
        Monad.Bind(
          BernoulliExpNeg.Model.Sample(Rationals.Int(1)),
          (a: bool) => SampleInnerLoopTailRecursive((a, if a then x.1 + 1 else x.1))
        )(s)
      else
        Monad.Return(x)(s)
  }

  /*******
   Lemmas
  *******/

  lemma SampleInnerLoopLiftToEnsures(s: Rand.Bitstream, t: Rand.Bitstream, a: bool, v: int)
    requires R1: !a 
    requires R2: SampleInnerLoopTailRecursive()(s) == SampleInnerLoopTailRecursive((a, v))(t)
    ensures Model.SampleInnerLoopFull()(s) == Monad.Result(v, t)
  {
    var f := (x: (bool, int)) => x.1;

    assert A: Model.SampleInnerLoop()(s) == Monad.Result((a, v), t) by {
      calc {
        Model.SampleInnerLoop()(s);
        Model.SampleInnerLoop((true, 0))(s);
        { SampleInnerLoopTailRecursiveEquivalence(s); }
        SampleInnerLoopTailRecursive((true, 0))(s);
        SampleInnerLoopTailRecursive()(s);
        { reveal R2; }
        SampleInnerLoopTailRecursive((a, v))(t);
        { reveal SampleInnerLoopTailRecursive(); reveal R1; }
        Monad.Return((a, v))(t);
        Monad.Result((a, v), t);
      }
    }

    calc {
      Model.SampleInnerLoopFull()(s);
      Model.SampleInnerLoop()(s).Map(f);
      { reveal A; }
      Monad.Result((a, v), t).Map(f);
      Monad.Result(v, t);
    }
  }

  lemma SampleInnerLoopTailRecursiveEquivalence(s: Rand.Bitstream, x: (bool, int) := (true, 0))
    decreases s
    ensures Model.SampleInnerLoop(x)(s) == SampleInnerLoopTailRecursive(x)(s)
  { 
    var r := Model.SampleInnerLoopBody(x)(s);
    Model.SampleInnerLoopTerminatesAlmostSurely();

    calc {
      Model.SampleInnerLoop(x)(s);
    == { reveal Loops.While(); }
      Loops.While(Model.SampleInnerLoopCondition, Model.SampleInnerLoopBody)(x)(s);
    ==  { Loops.WhileUnroll(Model.SampleInnerLoopCondition, Model.SampleInnerLoopBody, x, s); }
      if Model.SampleInnerLoopCondition(x) then 
        Monad.Bind(Model.SampleInnerLoopBody(x), (y: (bool, int)) => Model.SampleInnerLoop(y))(s)
      else
        Monad.Return(x)(s);
    == { reveal Model.SampleInnerLoopCondition();  }
      if x.0 then 
        if r.Result? then Model.SampleInnerLoop(r.value)(r.rest) else Monad.Diverging
      else 
        Monad.Return(x)(s);
    == { if r.Result? { SampleInnerLoopTailRecursiveEquivalence(r.rest, r.value); } }
      if x.0 then 
        if r.Result? then SampleInnerLoopTailRecursive(r.value)(r.rest) else Monad.Diverging
      else 
        Monad.Return(x)(s);
    ==
      if x.0 then 
        Monad.Bind(Model.SampleInnerLoopBody(x), SampleInnerLoopTailRecursive)(s)
      else 
        Monad.Return(x)(s);
    ==
      if x.0 then 
        Monad.Bind(
          Monad.Bind(
            BernoulliExpNeg.Model.Sample(Rationals.Int(1)), 
            (a: bool) => Monad.Return((a, if a then x.1 + 1 else x.1))
          ),
          SampleInnerLoopTailRecursive
        )(s)
      else 
        Monad.Return(x)(s);
    ==
      if x.0 then 
        Monad.Bind(
          BernoulliExpNeg.Model.Sample(Rationals.Int(1)), 
          (a: bool) => 
            Monad.Bind(
              Monad.Return((a, if a then x.1 + 1 else x.1)),
              SampleInnerLoopTailRecursive
            )
        )(s)
      else 
        Monad.Return(x)(s);
    == 
      if x.0 then
        Monad.Bind(
          BernoulliExpNeg.Model.Sample(Rationals.Int(1)),
          (a: bool) => SampleInnerLoopTailRecursive((a, if a then x.1 + 1 else x.1))
        )(s)
      else
        Monad.Return(x)(s);
    == { reveal SampleInnerLoopTailRecursive();  }
      SampleInnerLoopTailRecursive(x)(s);
    }
  }



}