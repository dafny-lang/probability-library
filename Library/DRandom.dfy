/*******************************************************************************
 *  Copyright by the contributors to the Dafny Project
 *  SPDX-License-Identifier: MIT
 *******************************************************************************/

// RUN: %verify "%s"

include "Model/RandomNumberGenerator.dfy"
include "Model/Model.dfy"
include "Model/Monad.dfy"
include "Model/Bernoulli.dfy"
include "Model/Uniform.dfy"

module {:extern "DafnyLibraries"} DafnyLibraries {
  import opened RandomNumberGenerator
  import opened Monad
  import opened Bernoulli
  import opened Unif = Uniform
  import opened Model

  // Only here because of #2500. Should really be imported from separate file.
  trait DRandomTrait {
    ghost var s: RNG

    method Coin() returns (b: bool)
      modifies this
      ensures CoinModel(old(s)) == (b, s)
  //  ensures forall b :: mu(iset s | Model.Coin(s).0 == b) == 0.5

    method Uniform(n: nat) returns (u: nat)
      modifies this
      requires 0 < n
      ensures UniformModel(n)(old(s)) == (u, s)
      decreases *
  //  ensures forall i | 0 <= i < n :: mu(iset s | Model.Uniform(n)(s).0 == i) == 1.0 / (n as real)

    method UniformInterval(a: int, b: int) returns (u: int)
      modifies this
      requires a < b
      ensures UniformIntervalModel(a, b)(old(s)) == (u, s)
      decreases *
  //  ensures forall i | a <= i < b :: mu(iset s | Model.UniformInterval(a, b)(s).0 == i) == 1.0 / ((b - a) as real)

    method Bernoulli(p: real) returns (c: bool) 
      modifies this
      decreases *            
      requires 0.0 <= p <= 1.0
      ensures BernoulliModel(p)(old(s)) == (c, s) 
  //  ensures mu(iset s | Model.Bernoulli(p)(s).0) == p
  }

  class {:extern} DRandom extends DRandomTrait {
    constructor {:extern} ()
    
    method {:extern} Coin() returns (b: bool)
      modifies this
      ensures CoinModel(old(s)) == (b, s)

    // Based on https://arxiv.org/pdf/1304.1916.pdf; unverified.
    method Uniform(n: nat) returns (u: nat)
      modifies this
      requires 0 < n
      ensures UniformModel(n)(old(s)) == (u, s)
      decreases *
    {
      assume {:axiom} false;
      var v := 1;
      u := 0;
      while true {
        v := 2 * v;
        var b := Coin();
        u := 2 * u + if b then 1 else 0;
        if v >= n {
          if u < n {
            return;
          } else {
            v := v - n;
            u := u - n;
          }
        }
      }
    }
    
    method UniformInterval(a: int, b: int) returns (u: int)
      modifies this
      requires a < b
      ensures UniformIntervalModel(a, b)(old(s)) == (u, s)
      decreases *
    {
      var v := Uniform(b - a);
      assert UniformModel(b-a)(old(s)) == (v, s);
      assert UniformIntervalModel(a, b)(old(s)) == (a + v, s);
      u := a + v;
    }

    method Bernoulli(p: real) returns (c: bool)
      modifies this 
      decreases *
      requires 0.0 <= p <= 1.0
      ensures BernoulliModel(p)(old(s)) == (c, s)
    {
      var q: Probability := p as real;

      var b := Coin();
      if b {
        if q <= 0.5 {
          return false;
        } else {
          q := 2.0 * (q as real) - 1.0;
        }
      } else {
        if q <= 0.5 {
          q := 2.0 * (q as real); 
        } else {
          return true;
        }
      }

      while true
        invariant BernoulliModel(p)(old(s)) == BernoulliModel(q)(s)
        decreases *
      {
        b := Coin();
        if b {
          if q <= 0.5 {
            return false;
          } else {
            q := 2.0 * (q as real) - 1.0;
          }
        } else {
          if q <= 0.5 {
            q := 2.0 * (q as real);
          } else {
            return true;
          }
        }
      }
    }
  }
}