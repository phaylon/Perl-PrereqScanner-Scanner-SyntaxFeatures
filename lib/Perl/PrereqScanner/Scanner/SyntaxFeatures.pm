use strictures 1;

# ABSTRACT:

package Perl::PrereqScanner::Scanner::SyntaxFeatures;
use Moose;
use Data::Dump qw( pp );

use syntax qw( simple/v2 );
use namespace::clean;

my $inflate = fun ($nick) {
    return join '::',
        qw( Syntax Feature ),
        map ucfirst,
        split m{/},
        join '',
        map ucfirst,
        split qr{_}, $nick;
};

method scan_for_prereqs ($ppi, $req) {
    my $found = $ppi->find(fun ($top, $current) {
        return unless $current->isa('PPI::Statement::Include');
        return unless $current->type eq 'use';
        my (undef, $module, @args) = $current->schildren;
        return unless $module;
        return unless $module->isa('PPI::Token::Word');
        return unless $module->literal eq 'syntax';
        return 1;
    });
    for my $node (@$found) {
        for my $child ($node->children) {
            if ($child->isa('PPI::Token::QuoteLike::Words')) {
                $req->add_minimum($_->$inflate, 0)
                    for $child->literal;
            }
            elsif ($child->isa('PPI::Token::Quote::Single')) {
                $req->add_minimum($child->literal->$inflate, 0);
            }
        }
    }
}

with 'Perl::PrereqScanner::Scanner';

1;

__END__

=head1 SYNOPSIS

    my $scanner = Perl::PrereqScanner->new(
        extra_scanners => [qw( SyntaxFeatures )],
    );

=head1 DESCRIPTION

This is a scanner plugin for L<Perl::PrereqScanner>. It will try to detect
required L<syntax> extensions from their usage in Perl code.

=head1 IMPLEMENTS

=over

=item * L<Perl::PrereqScanner::Scanner>

=back

=head1 METHODS

=head2 scan_for_prereqs

    $scanner->scan_for_prereqs($ppi_document, $requirements);

Required by L<Perl::PrereqScanner::Scanner>. Scans the passed L<PPI>
document and adds the detected extensions to the L<Version::Requirements>
object passed as second argument.

=head1 SEE ALSO

=over

=item * L<Perl::PrereqScanner>

=item * L<syntax>

=back

=cut
