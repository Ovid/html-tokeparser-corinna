use experimental 'class';

class HTML::TokeParser::Corinna::Token {
    use HTML::TokeParser::Corinna::Policy;

    method is_tag                 {false}
    method is_start_tag           {false}
    method is_end_tag             {false}
    method is_text                {false}
    method is_comment             {false}
    method is_declaration         {false}
    method is_pi                  {false}
    method is_process_instruction {false}
}

1;

__END__

=head1 NAME

HTML::TokeParser::Corinna::Token - Base class for C<HTML::TokeParser::Corinna>
tokens.

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $p = HTML::TokeParser::Corinna->new( file => $somefile );
   
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->to_string;
    }

=head1 DESCRIPTION

This is the abstract base class for all returned tokens.

=head1 METHODS

The following list of methods are provided by this class.  Most of these are
stub methods which must be overridden in a subclass.  See 
L<HTML::TokeParser::Corinna> for descriptions of these methods.

=over 4

=item * to_string

=item * delete_attr

=item * attr

=item * attrseq

=item * tag

=item * token0

=item * is_comment

=item * is_declaration

=item * is_end_tag

=item * is_pi

=item * is_process_instruction

=item * is_start_tag

=item * is_tag

=item * is_text

=item * return_attr

=item * return_attrseq

=item * return_tag

=item * return_text

=item * return_token0

=item * rewrite_tag

=item * set_attr

=back
