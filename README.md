# VMC: a Library for Verified Monte Carlo Algorithms

The `DafnyVMC` module introduces utils for probabilistic reasoning in Dafny. At the moment, the API is intentionally limited in scope, and only supports compilation to Java. For the future, we plan to extend both the functionality and the range of supported languages.

## Java API Example

```java
import DafnyVMC.Random;
import java.math.BigInteger;
import java.util.Arrays;

class Test {
  DafnyVMC.Random r = new DafnyVMC.Random();

  char[] arr = {'a', 'b', 'c'};
  Rationals.Rational gamma = new Rationals.Rational(BigInteger.valueOf(3), BigInteger.valueOf(5));

  System.out.println("Example of Fisher-Yates: char");
  r.Shuffle(arr);
  System.out.println(Arrays.toString(arr));

  System.out.println("Example of Bernoulli sampling");
  System.out.println(r.BernoulliSample(gamma));
}
```

## Dafny Examples

To run the examples in the `docs/dafny` directory, use the following commands:

```bash
# Dafny Examples
$ dafny build docs/dafny/ExamplesRandom.dfy --target:java src/interop/java/Full/Random.java src/interop/java/Part/Random.java dfyconfig.toml --no-verify
$ java -jar docs/dafny/ExamplesRandom.jar
```

## Java Examples

To run the examples in the `docs/java` directory, use the following commands:

```bash
# Java Examples
$ bash scripts/build.sh 
$ bash build/java/run.sh  
```

## Dafny Testing

To run the statistical tests in the `tests` directory, use the following commands:

```bash
# Dafny Tests
$ dafny test --target:java src/interop/java/Full/Random.java src/interop/java/Part/Random.java tests/TestsRandom.dfy tests/Tests.dfy dfyconfig.toml --no-verify
```



