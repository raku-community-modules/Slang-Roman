# Integer value to character mapping
my constant %num-map =
        1 => 'I',
        5 => 'V',
       10 => 'X',
       50 => 'L',
      100 => 'C',
      500 => 'D',
    1_000 => 'M',
    5_000 => 'ↁ',  # 2181 ROMAN NUMERAL FIVE THOUSAND
   10_000 => 'ↂ',  # 2182 ROMAN NUMERAL TEN THOUSAND
   50_000 => 'ↇ',  # 2187 ROMAN NUMERAL FIFTY THOUSAND
  100_000 => 'ↈ',  # 2188 ROMAN NUMERAL ONE HUNDRED THOUSAND
;

# Character to integer value mapping
my constant %char-map =
     I  =>       1,
    "Ⅰ" =>       1,  # 2160 ROMAN NUMERAL ONE
    "Ⅱ" =>       2,  # 2161 ROMAN NUMERAL TWO
    "Ⅲ" =>       3,  # 2162 ROMAN NUMERAL THREE
    "Ⅳ" =>       4,  # 2163 ROMAN NUMERAL FOUR
     V  =>       5,
    "Ⅴ" =>       5,  # 2164 ROMAN NUMERAL FIVE
    "Ⅵ" =>       6,  # 2165 ROMAN NUMERAL SIX
    "Ⅶ" =>       7,  # 2166 ROMAN NUMERAL SEVEN
    "Ⅷ" =>       8,  # 2167 ROMAN NUMERAL EIGHT
    "Ⅸ" =>       9,  # 2168 ROMAN NUMERAL NINE
     X  =>      10,
    "Ⅹ" =>      10,  # 2169 ROMAN NUMERAL TEN
    "Ⅺ" =>      11,  # 216A ROMAN NUMERAL ELEVEN
    "Ⅻ" =>      12,  # 216B ROMAN NUMERAL TWELVE
     L  =>      50,
    "Ⅼ" =>      50,  # 216C ROMAN NUMERAL FIFTY
     C  =>     100,
    "Ⅽ" =>     100,  # 216D ROMAN NUMERAL ONE HUNDRED
     D  =>     500,
    "Ⅾ" =>     500,  # 216E ROMAN NUMERAL FIVE HUNDRED
     M  =>   1_000,
    "Ⅿ" =>   1_000,  # 216F ROMAN NUMERAL ONE THOUSAND
    "ↀ" =>   1_000,  # 2180 ROMAN NUMERAL ONE THOUSAND C D
    "ↁ" =>   5_000,  # 2181 ROMAN NUMERAL FIVE THOUSAND
    "ↂ" =>  10_000,  # 2182 ROMAN NUMERAL TEN THOUSAND
    "ↇ" =>  50_000,  # 2187 ROMAN NUMERAL FIFTY THOUSAND
    "ↈ" => 100_000,  # 2188 ROMAN NUMERAL ONE HUNDRED THOUSAND
;

# Convert a given integer value to a Roman numeral string
my constant @nums = %num-map.keys.sort(*.Int).reverse;
my sub to-roman(Int:D $val) is export {
    my $current = $val;
    my str @parts;

    for @nums -> $value {
        while $value <= $current {
            $current -= $value;
            @parts.push: %num-map{$value};
        }
    }
    @parts.join
}

# Convert a given string consisting of Roman numerals to an integer value
my sub to-number(Str:D $value) is export {

    # Find subtractives and convert them to additives

    my %subtractives = (
        IV =>  'IIII',  #( 5 - 1 == 4 )
        IX => 'VIIII',  #( 10 - 1 == 9 )
        XL =>  'XXXX',  #( 50 - 10 == 40 )
        XC => 'LXXXX',  #( 100 - 10 == 90 )
        CD =>  'CCCC',  #( 500 - 100 == 400 )
        CM => 'DCCCC',  #( 1000 - 100 == 900 )
    );

    my Pair $p = (.keys => .values) given %subtractives;

    $value
        .trans( $p )
        .comb.map({
            %char-map{$_} // die "Unexpected '$_' in Roman numeral"
        })
        .sum
}

my role Grammar {
    # Patch the <number> rule to add our own numeric type.
    #
    # Describes a Roman number.  Takes any additional word characters
    # to be able to produce a better error message at compilation time
    token number:sym<roman> {
        '0r' <( <[ I V X L C D M Ⅰ .. Ⅿ ↀ ↁ ↂ ↇ ↈ  \w ]>+
    }
}

my role Actions {
    method number:sym<roman>(Mu $/) {
        CATCH { OUTER::<$/>.panic: .message }
        my $value := to-number($/.Str);

        # Running under the Raku grammar
        if self.^name.starts-with('Raku::') {
            use experimental :rakuast;
            my class RakuAST::RomanLiteral is RakuAST::IntLiteral {
                my class Roman {
                    has $.value;
                    method raku() { '0r' ~ to-roman($!value) }
                }
                method value() { Roman.new(value => callsame) }
            }
            make RakuAST::RomanLiteral.new($value);
        }

        # Running under the legacy grammar
        else {
            use QAST:from<NQP>;
            make QAST::IVal.new(:$value);
        }
    }
}

use Slangify Grammar, Actions;

=begin pod

=head1 NAME

Slang::Roman - lets you use Roman numerals in your code

=head1 SYNOPSIS

=begin code :lang<raku>

use Slang::Roman;

say 0rI + 0rIX; # 10
my $i = 0rMMXVI; # $i = 2016

=end code

=head1 DESCRIPTION

This bit of admittedly twisted code let you use Roman numerals in your Raku code. It patches the running grammar so you can use a Roman numeral anywhere you would use a regular integer.

Future enhancements will include expansions to printf/sprintf with a custom formatting type, and the equivalents of C<hex()> to handle string conversion.

While it handles both additive and subtractive Roman numerals, it doesn't check that they're properly formatted. For instance 'IC' should be a compile-time error but instead it'll generate 101 as if nothing of consequence happened.

=head1 REFERENCE

According to L<Wikipedia|https://en.wikipedia.org/wiki/Roman_numerals>, the standard form is:

=begin table
| # | Thousands | Hundreds | Tens | Units |
|---|-----------|----------|------|-------|
| 1 | M         | C        | X    | I     |
| 2 | MM        | CC       | XX   | II    |
| 3 | MMM       | CCC      | XXX  | III   |
| 4 |           | CD       | XL   | IV    |
| 5 |           | D        | L    | V     |
| 6 |           | DC       | LX   | VI    |
| 7 |           | DCC      | LXX  | VII   |
| 8 |           | DCCC     | LXXX | VIII  |
| 9 |           | CM       | XC   | IX    |
=end table

The numerals for 4 (IV) and 9 (IX) are written using subtractive notation,where the smaller symbol (I) is subtracted from the larger one (V, or X), thus avoiding the clumsier IIII and VIIII. Subtractive notation is also used for 40 (XL), 90 (XC), 400 (CD) and 900 (CM). These are the only subtractive forms in standard use.

=head1 AUTHOR

Jeff Goff (DrForr)

Source can be located at: https://github.com/raku-community-modules/Slang-Roman .
Comments and Pull Requests are welcome.

=head1 COPYRIGHT AND LICENSE

Copyright 2016, 2018 Jeff Goff, 2020-2023 Raku Community

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

=end pod

# vim: expandtab shiftwidth=4
