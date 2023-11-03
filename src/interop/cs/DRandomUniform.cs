/*******************************************************************************
*  Copyright by the contributors to the Dafny Project
*  SPDX-License-Identifier: MIT
*******************************************************************************/

using System;
using System.Numerics;

namespace Uniform_mImplementation {

    public class DRandomUniform : Coin_mInterface.DRandomCoin {

      /// Generates a uniformly random BigInteger between 0 (inclusive) and 2^bitLength (exclusive)
      private static BigInteger UniformPowerOfTwo(int bitLength) {
        if (bitLength < 1) {
          return BigInteger.Zero;
        }

        int numBytes = bitLength / 8;
        int numBits = bitLength % 8;

        byte[] randomBytes = rng.GetBytes(numBytes + 1);

        // Mask out the top bits:
        byte mask = (byte)(0xFF >> (8 - numBits));
        randomBytes[numBytes] &= mask;

        return new BigInteger(randomBytes);
      }

      public static BigInteger Uniform(BigInteger n) {
        if (n <= BigInteger.Zero) {
          throw new ArgumentException("n must be positive");
        }

        BigInteger sampleValue;
        do {
          sampleValue = UniformPowerOfTwo(System.Convert.ToInt32(n.GetBitLength()));
        } while (sampleValue >= n);

        return sampleValue;
      }

  }

}
