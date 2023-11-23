/*******************************************************************************
 *  Copyright by the contributors to the Dafny Project
 *  SPDX-License-Identifier: MIT
 *******************************************************************************/

module DiscreteLaplace.Model {
  import Monad
  import Rand
  import Rationals
  import Uniform
  import BernoulliExpNeg
  import Coin
  import Loops

  /************
   Definitions
  ************/

  ghost function Sample(scale: Rationals.Rational): Monad.Hurd<int>
    requires scale.numer >= 1
  {
    var f := (x: (bool, int)) => if x.0 then -x.1 else x.1;
    Monad.Map(SampleLoop(scale), f)
  }

  ghost function SampleLoop(scale: Rationals.Rational): Monad.Hurd<(bool, int)>
    requires scale.numer >= 1
  {
    Loops.While(Condition, Body(scale))((true, 0))
  }

  ghost function Body(scale: Rationals.Rational): ((bool, int)) -> Monad.Hurd<(bool, int)>
    requires scale.numer >= 1
  {
    // replace with functional version
    (x: (bool, int)) =>
      (s: Rand.Bitstream) =>
        var (b, y) := (x.0, x.1);
        var (u, s) :- Uniform.Model.Sample(scale.numer)(s);
        var (d, s) :- BernoulliExpNeg.Model.Sample(Rationals.Rational(u, scale.numer))(s);
        if d then
          var (v, s) :- SampleHelper()(s);
          var x := u + scale.numer * v;
          var y := x / scale.denom;
          var (b, s) :- Coin.Model.Sample(s);
          Monad.Result((b, y), s)
        else
          Monad.Result((b, y), s)
  }

  ghost function Condition(x: (bool, int)): bool {
    x.0 && x.1 == 0
  }

  ghost function SampleHelper(a: bool := true, v: int := 0): Monad.Hurd<int> {
    // add functional version
    (s: Rand.Bitstream) => Monad.Result(1, s)
  }
}