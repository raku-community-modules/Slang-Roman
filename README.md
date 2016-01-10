#Slang::Roman

Allow your integers to be Roman numerals.

* my Int $r = 0rMMCXVI; # $r == 2016
* printf "%{roman}d", $r; # MMCXVI

What it doesn't do [yet]

* printf
* the rest.

#Use

```perl6
use Slang::Roman;

say 0rIV;
```

```Output:

4
```

##Better Examples

Check out ```t/01_basic.t```
