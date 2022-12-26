use experimental 'class';
class HTML::TokeParser::Corinna {
    use Carp 'croak';
    use HTML::TokeParser;
    use HTML::TokeParser::Corinna::Token;
    use HTML::TokeParser::Corinna::Token::Tag;
    use HTML::TokeParser::Corinna::Token::Tag::Start;
    use HTML::TokeParser::Corinna::Token::Tag::End;
    use HTML::TokeParser::Corinna::Token::Text;
    use HTML::TokeParser::Corinna::Token::Comment;
    use HTML::TokeParser::Corinna::Token::Declaration;
    use HTML::TokeParser::Corinna::Token::ProcessInstruction;

    # should be class data
    my %TOKEN_CLASSES = (
        S   => 'HTML::TokeParser::Corinna::Token::Tag::Start',
        E   => 'HTML::TokeParser::Corinna::Token::Tag::End',
        T   => 'HTML::TokeParser::Corinna::Token::Text',
        C   => 'HTML::TokeParser::Corinna::Token::Comment',
        D   => 'HTML::TokeParser::Corinna::Token::Declaration',
        PI  => 'HTML::TokeParser::Corinna::Token::ProcessInstruction',
    );

    field $html :param;
    field $parser;

    ADJUST {
        $parser = HTML::TokeParser->new( \$html );
    }

    method get_token (@args) {
        my $token = $parser->get_token( @args ) or return;
        if (my $factory_class = $TOKEN_CLASSES{$token->[0]}) {
            return $factory_class->new( token => $token );
        }
        else {
            # this should never happen
            croak("Cannot determine token class for token (@$token)");
        }
    }

    method get_tag(@args) {
        my $token = $parser->get_tag(@args) or return;

        # for some reason, HTML::Parser strips the leading letter if we
        # fetch tags directory
        my $is_start = $token->[0] !~ /^\//;
        unshift @$token => $is_start ? 'S' : 'E';
        return $is_start
          ? HTML::TokeParser::Corinna::Token::Tag::Start->new( token => $token )
          : HTML::TokeParser::Corinna::Token::Tag::End->new( token => $token );
    }

    method peek ($count = 1) {
        unless ($count =~ /^\d+$/) {
            croak("Argument to peek() must be a positive integer, not ($count)");
        }

        my $items = 0;
        my @tokens;
        while ( $items++ < $count && defined ( my $token = $self->get_token ) ) {
            push @tokens, $token;
        }
        $parser->unget_token(@tokens);
        return \@tokens;
    }
}

1;

__END__

=head1 NAME

HTML::TokeParser::Corinna - HTML::TokeParser::Simple rewritten in Corinna

=head1 SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $parser = HTML::TokeParser::Corinna->new( html => $test_html );
    
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->to_string;
    }

=head1 DESCRIPTION

This is a "work in pogress" to test out Corinna and her features. It's similar
to L<HTML::TokeParser::Simple>, but the latter is a drop-in replacement for
C<HTML::TokeParser> and this module is not (it can't be because we're not
blessing array references).

It's not well-documented because it's not intended for production release,
though there are a few nits in the code cleaned up.
