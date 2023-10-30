/*******************************************************************************
 *  Copyright by the contributors to the Dafny Project
 *  SPDX-License-Identifier: MIT
 *******************************************************************************/

module BernoulliExpNeg.Implementation {
  import Helper
  import Rationals
  import Rand
  import Monad
  import Interface
  import Model
  import Bernoulli
  import Equivalence

  trait {:termination false} Trait extends Interface.Trait {

    // Based on Algorithm 1 in https://arxiv.org/pdf/2004.00010.pdf; unverified
    method BernoulliExpNegSample(gamma: Rationals.Rational) returns (c: bool)
      modifies this
      requires gamma.numer >= 0
      decreases *
      ensures Monad.Result(c, s) == Model.Sample(gamma)(old(s))
    {
      var gamma' := gamma;
      var b := true;
      while b && gamma'.numer >= gamma'.denom
        decreases gamma'.numer
        invariant gamma'.numer >= 0
        invariant Model.GammaReductionLoop((true, gamma))(old(s)) == Model.GammaReductionLoop((b, gamma'))(s)
      {
        b := BernoulliExpNegSampleCaseLe1(Rationals.Int(1));
        gamma' := Rationals.Rational(gamma'.numer - gamma'.denom, gamma'.denom);
      }
      if b {
        c:= BernoulliExpNegSampleCaseLe1(gamma');
      } else {
        c := false;
      }
      reveal Model.Sample();
    }

    method BernoulliExpNegSampleCaseLe1(gamma: Rationals.Rational) returns (c: bool)
      modifies this
      requires 0 <= gamma.numer <= gamma.denom
      decreases *
      ensures Monad.Result(c, s) == Model.SampleGammaLe1(gamma)(old(s))
    {
      var k: nat := 0;
      var a := true;
      Equivalence.EnsureCaseLe1LoopInvariantOnEntry(gamma, s);
      while a
        decreases *
        invariant Equivalence.CaseLe1LoopInvariant(gamma, old(s), a, k, s)
      {
        ghost var prevK: nat := k;
        ghost var prevS := s;
        k := k + 1;
        Helper.MulMonotonic(1, gamma.denom, k, gamma.denom);
        a := BernoulliSample(Rationals.Rational(gamma.numer, k * gamma.denom));
        Equivalence.EnsureCaseLe1LoopInvariantMaintained(gamma, old(s), prevK, prevS, a, k, s);
      }
      c := k % 2 == 1;
      Equivalence.EnsureCaseLe1PostCondition(gamma, old(s), k, s, c);
    }
  }

}
