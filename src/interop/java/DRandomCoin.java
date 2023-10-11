package Coin_mInterface;

import java.security.SecureRandom;
import java.math.BigInteger;
import java.lang.Thread;

public final class DRandomCoin {

  private static final ThreadLocal<SecureRandom> RNG = ThreadLocal.withInitial(DRandomCoin::createSecureRandom);

  private DRandomCoin() {}

  private static final SecureRandom createSecureRandom() {
    final SecureRandom rng = new SecureRandom();
    rng.nextBoolean(); 
    return rng;
}

  public static boolean Coin() {
    return RNG.get().nextBoolean();
  }

}