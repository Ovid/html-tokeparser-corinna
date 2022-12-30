use experimental 'class';

class HTML::TokeParser::Corinna::Token::Tag::End : isa(HTML::TokeParser::Corinna::Token::Tag) {
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    # ["E",  $tag, $text]
    field $token : param;
    field $tag       = $token->[1];
    field $to_string = $token->[2];

    method tag       {$tag}
    method to_string {$to_string}

    method is_end_tag ( $maybe_tag = undef ) {
        return true unless defined $maybe_tag;
        return lc $maybe_tag eq lc $tag;
    }

    method rewrite_tag {
        $to_string = sprintf "</%s>" => $tag;
    }
}

1;

__END__

=head1 NAME

HTML::TokeParser::Corinna::Token::Tag::End - Token.pm "end tag" class.

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $p = HTML::TokeParser::Corinna->new( file => $somefile );
   
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->to_string;
    }

=head1 DESCRIPTION

This class does most of the heavy lifting for C<HTML::TokeParser::Corinna>.  See
the C<HTML::TokeParser::Corinna> docs for details.

=head1 OVERRIDDEN METHODS

=over 4

=item * to_string

=item * tag

=item * is_end_tag

=item * is_tag

=item * text

=item * rewrite_tag

=back

=cut
