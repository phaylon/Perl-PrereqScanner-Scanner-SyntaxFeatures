use strictures 1;
use Test::More;

use Perl::PrereqScanner;
use Perl::PrereqScanner::Scanner::SyntaxFeatures;

sub is_required;

my $scanner = Perl::PrereqScanner
    ->new(scanners => [qw( SyntaxFeatures )]);

my $requires = $scanner->scan_string(q{
    package Foo;
    use syntax qw( foo bar );
    use syntax 'baz', 'qux_quux';
    use syntax qw( foo/bar );
    use syntax 'f3/x7';
    1;
})->as_string_hash;

is_required 'Foo',      'detected simple word in qw';
is_required 'Bar',      'detected second simple word in qw';
is_required 'Baz',      'detected simple string';
is_required 'QuxQuux',  'transformation with underscore';
is_required 'Foo::Bar', 'transformation of slashed subsyntax module';
is_required 'F3::X7',   'transformation with numbers and slashes';

$requires = $scanner
    ->scan_file($INC{'Perl/PrereqScanner/Scanner/SyntaxFeatures.pm'})
    ->as_string_hash;

is_required 'Simple::V2', 'scanner can scan itself';

done_testing;

sub is_required {
    my ($postfix, $title) = @_;
    ok defined($requires->{"Syntax::Feature::$postfix"}), $title;
}
