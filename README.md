[![Actions Status](https://github.com/raku-community-modules/Slang-Roman/workflows/test/badge.svg)](https://github.com/raku-community-modules/Slang-Roman/actions)

NAME
====

Slang::Roman - lets you use Roman numerals in your code

SYNOPSIS
========

```raku
use Slang::Roman;

say 0rI + 0rIX; # 10
my $i = 0rMMXVI; # $i = 2016
```

DESCRIPTION
===========

This bit of admittedly twisted code let you use Roman numerals in your Raku code. It patches the running grammar so you can use a Roman numeral anywhere you would use a regular integer.

Future enhancements will include expansions to printf/sprintf with a custom formatting type, and the equivalents of `hex()` to handle string conversion.

While it handles both additive and subtractive Roman numerals, it doesn't check that they're properly formatted. For instance 'IC' should be a compile-time error but instead it'll generate 101 as if nothing of consequence happened.

AUTHOR
======

Jeff Goff (DrForr)

Source can be located at: https://github.com/raku-community-modules/Slang-Roman . Comments and Pull Requests are welcome.

COPYRIGHT AND LICENSE
=====================

Copyright 2016, 2018 Jeff Goff, 2020-2023 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

