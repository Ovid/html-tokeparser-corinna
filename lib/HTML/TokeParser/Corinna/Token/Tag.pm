use experimental 'class';
class HTML::TokeParser::Corinna::Token::Tag : isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    method is_tag {true}
    method tag                    { }
}

1;

__END__

=head1 NAME

HTML::TokeParser::Corinna::Token::Tag - Token.pm tag class.

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $p = HTML::TokeParser::Corinna->new( file => $somefile );
   
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->to_string;
    }

=head1 DESCRIPTION

This is the base class for start and end tokens.  It should not be
instantiated.  See C<HTML::TokeParser::Corinna::Token::Tag::Start> and
C<HTML::TokeParser::Corinna::Token::Tag::End> for details.

=head1 OVERRIDDEN METHODS

The following list of methods are provided by this class.  See
L<HTML::TokeParser::Corinna> for descriptions of these methods.

=over 4

=item * to_string

=item * tag

=item * text

=back
