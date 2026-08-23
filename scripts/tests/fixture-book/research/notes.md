# Fixture research note

The number check only runs when a book has research notes, so this file is what
switches it on. It records one measurement and deliberately does not record the
other one the prose prints.

Traced: the run took 1.25 seconds.

Traced capture, quoted so the verbatim check has something to accept:

```
this line was really captured
```

A traced capture this note folds and the page does not, which is what a long
capture looks like in a real note. The fold is mid-token, so collapsing
whitespace to a space rather than removing it puts a space between the comma
and the next key that the page's single line has not got, and reports a capture
recorded right here as untraced.

```
{"errors":[{"message":"no such field",
"line":14}]}
```
