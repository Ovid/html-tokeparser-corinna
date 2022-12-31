use experimental 'class';

class HTML::TokeParser::Corinna::Token::ProcessInstruction : isa(HTML::TokeParser::Corinna::Token) {
    use HTML::TokeParser::Corinna::Policy;

    # ["PI", $token0, $text]
    field $token : param;
    field $token0;
    field $to_string;
    ADJUST { (undef, $token0, $to_string ) = $token->@*; }

    method tag                    { }
    method token0                 {$token0}
    method to_string              {$to_string}
    method is_pi                  {true}
    method is_process_instruction {true}
}

1;
__END__

=head1 NAME

HTML::TokeParser::Corinna::Token::ProcessInstruction - Token.pm process instruction class.

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $p = HTML::TokeParser::Corinna->new( file => $somefile );

    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->as_is;
    }

=head1 DESCRIPTION

Process Instructions are from XML.  This is very handy if you need to parse out
PHP and similar things with a parser.

Currently, there appear to be some problems with process instructions.  You can
override this class if you need finer grained handling of process instructions.

C<is_pi()> and C<is_process_instruction()> both return true.

=head1 OVERRIDDEN METHODS

=over 4

=item * token0

=item * is_pi

=item * is_process_instruction

=item * return_token0

=back

=cut
