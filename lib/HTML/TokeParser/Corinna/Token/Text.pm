use experimental 'class';

class HTML::TokeParser::Corinna::Token::Text : isa(HTML::TokeParser::Corinna::Token) {
    use HTML::TokeParser::Corinna::Policy;

    # ["T",  $text, $is_data]
    field $token : param;
    field $to_string = $token->[1];
    field $is_data   = $token->[2];

    method is_text   {true}
    method to_string {$to_string}
    method is_data   {$is_data}
}

1;
__END__

=head1 NAME

HTML::TokeParser::Corinna::Token::Text - Token.pm text class.

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $p = HTML::TokeParser::Corinna->new( file => $somefile );
   
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->as_is;
    }

=head1 DESCRIPTION

This class represents "text" tokens.  See the C<HTML::TokeParser::Corinna>
documentation for details.

=head1 OVERRIDDEN METHODS

=over 4

=item * to_string

=back

=cut
