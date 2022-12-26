# NAME

HTML::TokeParser::Corinna - HTML::TokeParser::Simple rewritten in Corinna

# SYNOPSIS

    use HTML::TokeParser::Corinna;
    my $parser = HTML::TokeParser::Corinna->new( html => $test_html );
    
    while ( my $token = $p->get_token ) {
        # This prints all text in an HTML doc (i.e., it strips the HTML)
        next unless $token->is_text;
        print $token->to_string;
    }

# DESCRIPTION

This is a "work in pogress" to test out Corinna and her features. It's similar
to
[HTML::TokeParser::Simple](https://metacpan.org/pod/HTML::TokeParser::Simple),
but the latter is a drop-in replacement for
[HTML::TokeParser](https://metacpan.org/pod/HTML::TokeParser) and this module
is not (it can't be because we're not blessing array references).

It's not well-documented because it's not intended for production release,
though there are a few nits in the code cleaned up.

Corinna is still a work in progress, so we'll be updating this code later.
