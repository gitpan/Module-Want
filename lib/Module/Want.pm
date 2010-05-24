package Module::Want;

# use warnings;
# use strict;

$Module::Want::VERSION = '0.1';

my %lookup;

# Uncomment these 3 lines and '        # $tries{$ns}++;' in have_mod() for dev testing
# $Module::Want::DevTesting = 1;
# my %tries;
# sub _get_debugs_refs { return \%lookup, \%tries }

sub have_mod {
    my ($ns, $skip_cache) = @_;
    $skip_cache ||= 0 ;
    
    if ( $ns !~ m/^\A[A-Za-z_](?:[A-Za-z0-9_]*)(?:(?:\:\:|\')[A-Za-z0-9_]+)*\z/ ) {
        require Carp;
        Carp::carp('Invalid Namespace');
        return;
    }

    if ( $skip_cache || !exists $lookup{$ns} ) {
        $lookup{$ns} = 0;
        # $tries{$ns}++;
        eval qq{
           require $ns;
           \$lookup{\$ns}++;
        };
    }

    return $lookup{$ns} if $lookup{$ns};
    return;
}

sub import {
    shift;

    # no strict 'refs';
    *{ caller() . '::have_mod' } = \&have_mod;

    for my $ns (@_) {
        have_mod($ns);
    }
}

1;

__END__

=head1 NAME

Module::Want - Check @INC once for modules that you want but may not have

=head1 VERSION

This document describes Module::Want version 0.1

=head1 SYNOPSIS

    use Module::Want;

    if (have_mod('Encode')) {
        ... use Encode::whatever ...
    }
    else {
        ... use Encode:: alternative ...
    }

=head1 DESCRIPTION

Sometimes you want to lazy load a module for use in, say, a loop or function. First you do the eval-require but then realize if the module is not available it will re-search @INC each time. So then you add a lexical boolean to your eval and do the same simple logic all over the place. On and on it goes :)

This module encapsulates that logic so that have_mod() is like eval { require X; 1 } but if the module can't be loaded it will remember that fact and not look in @INC again on subsequent calls.

For example, this searches @INC for X.pm every iteration of the loop:

    while( ... ) {
        if (eval { require X; 1 }) {
            ... use X code ...
        }
        else {
            ... do X-alternative code ...
        }
    }

This searches @INC for X.pm once:
    
    while( ... ) {
        if (have_mod('X')) {
            ... use X code ...
        }
        else {
            ... do X-alternative code ...
        }
    }

=head1 INTERFACE 

import() puts have_mod() into the caller's name space.

=head2 have_mod()

Takes the name space to require() if we have not tried already.

Returns true if it could be loaded. False otherwise.

You can give it a second true argument to skip using the value from the last time it was called and re-try require()ing it.

   if (!have_mod('X')) {
       # do some things to try and ger X available 
   }
   
   if (have_mod('X',1)) {
       # sweet we have it now!
   }

=head2 import()

You can use() it with a list to call have_mod() on:

   use Module::Want qw(X Y Z); # calls have_mod('X'), have_mod('Y'), and have_mod('Z')

=head1 DIAGNOSTICS

=over

=item C<< Invalid Namespace >>

The argument to have_mod() is not a name space

=back

=head1 CONFIGURATION AND ENVIRONMENT

Module::Want requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-module-want@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Daniel Muey  C<< <http://drmuey.com/cpan_contact.pl> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2010, Daniel Muey C<< <http://drmuey.com/cpan_contact.pl> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.