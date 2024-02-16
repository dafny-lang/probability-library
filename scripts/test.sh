#!/bin/bash

set -e

if [ -z ${DAFNY+x} ]
then
  echo "Set the DAFNY variable"
  exit 1
fi

if [ -z ${TARGET_LANG+x} ]
then
  echo "Set the TARGET_LANG variable"
  exit 1
fi

echo Running $TARGET_LANG tests...

echo "Running tests/TestsRandom.dfy:"
if [ "$TARGET_LANG" = "py" ]
then
  time $DAFNY test --target:$TARGET_LANG src/interop/$TARGET_LANG/Full/DafnyVMC.$TARGET_LANG src/interop/$TARGET_LANG/Part/DafnyVMCPartMaterial.$TARGET_LANG tests/TestsRandom.dfy tests/Tests.dfy dfyconfig.toml  --no-verify
else
  time $DAFNY test --target:$TARGET_LANG src/interop/$TARGET_LANG/Full/Random.$TARGET_LANG src/interop/$TARGET_LANG/Part/Random.$TARGET_LANG tests/TestsRandom.dfy tests/Tests.dfy dfyconfig.toml  --no-verify
fi

echo Running $TARGET_LANG documentation...

echo "Building docs/dafny/ExamplesRandom.dfy..." 
if [ "$TARGET_LANG" = "py" ]
then
  time $DAFNY build docs/dafny/ExamplesRandom.dfy --target:$TARGET_LANG src/interop/$TARGET_LANG/Full/DafnyVMC.$TARGET_LANG src/interop/$TARGET_LANG/Part/DafnyVMCPartMaterial.$TARGET_LANG dfyconfig.toml --no-verify
else
  time $DAFNY build docs/dafny/ExamplesRandom.dfy --target:$TARGET_LANG src/interop/$TARGET_LANG/Full/Random.$TARGET_LANG src/interop/$TARGET_LANG/Part/Random.$TARGET_LANG dfyconfig.toml --no-verify
fi

echo "Executing compiled docs/dafny/ExamplesRandom.dfy:" 
if [ "$TARGET_LANG" = "java" ]
then
  java -jar docs/dafny/ExamplesRandom.jar
else
  python3 docs/dafny/ExamplesRandom-py/__main__.py
fi
