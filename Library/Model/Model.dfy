/*******************************************************************************
*  Copyright by the contributors to the Dafny Project
*  SPDX-License-Identifier: MIT
*******************************************************************************/

include "Uniform.dfy"
include "Monad.dfy"
include "RandomNumberGenerator.dfy"
include "Bernoulli.dfy"

module Model {
  import opened Monad
  import opened RandomNumberGenerator
  import opened Unif = Uniform
  import opened Bern = Bernoulli

  function CoinModel(s: RNG): (bool, RNG) {
    Monad.Deconstruct(s)
  }

  function UniformPowerOfTwoModel(n: nat, k: nat := 1, u: nat := 0): Hurd<nat> 
    requires k >= 1
  {
    (s: RNG) => Unif.ProbUnifAlternative(n, s, k, u)
  }

  function UniformModel(n: nat): Hurd<nat> 
    requires 0 < n 
  {
    Unif.ProbUniform(n)
  }

  function UniformIntervalModel(a: int, b: int): (f: Hurd<int>)
    requires a < b
    ensures forall s :: f(s).0 == a + UniformModel(b - a)(s).0
  {
    Unif.ProbUniformInterval(a, b)
  }

  function BernoulliModel(p: Probability): Hurd<bool> {
    Bern.ProbBernoulli(p)
  }

}