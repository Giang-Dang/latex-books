# Fixture research note

Not a real note. It exists so that
`scripts/tests/fixture-punctuation/chapters/01-modes/03-captured.tex` has
something for a captured line to trace to, which is half of what
`Characters.AllowInCapturedListings` requires.

The line below is quoted by three of that file's four cases. Only the one that
is inside an environment the setting names may be forgiven; being in this file
is not on its own enough.

```
The generated config keeps the directive—this time without its argument.
```

The line case 2 uses is deliberately absent, so that a listing in the right
environment can still fail to trace.
