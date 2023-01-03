package HTML::TokeParser::Corinna::Policy {
    use v5.37.8;
    use strict;
    use warnings;
    use feature ();
    use namespace::autoclean;
    use HTML::TokeParser::Corinna::Utils;

    use Import::Into;

    sub import {
        my ($class) = @_;

        my $caller = caller;

        warnings->import;
        warnings->unimport('experimental');
        builtin->import::into( $caller, 'true', 'false' );
        strict->import;
        feature->import(qw/:5.37.8 try class/);
        namespace::autoclean->import::into($caller);
        HTML::TokeParser::Corinna::Utils->import::into( $caller, 'throw' );
    }
}

1;

__END__

=head1 NAME

HTML::TokeParser::Corinna::Policy - Common software behavior

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna::Policy;

=head1 DESCRIPTION

This module is a replacement for the following:

    use v5.37.8;
    use warnings;
    no warnings 'experimental';
    use namespace::autoclean;
    use feature qw(try class);
    use builtin qw(true false);
    use HTML::TokeParser::Corinna::Utils 'throw';
