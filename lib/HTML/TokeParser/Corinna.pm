use v5.27.8;
use experimental 'class';
class HTML::TokeParser::Corinna {
    use Carp 'croak';
    use HTML::TokeParser 3.25;

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
        S  => 'HTML::TokeParser::Corinna::Token::Tag::Start',
        E  => 'HTML::TokeParser::Corinna::Token::Tag::End',
        T  => 'HTML::TokeParser::Corinna::Token::Text',
        C  => 'HTML::TokeParser::Corinna::Token::Comment',
        D  => 'HTML::TokeParser::Corinna::Token::Declaration',
        PI => 'HTML::TokeParser::Corinna::Token::ProcessInstruction',
    );

    field $html : param = undef;
    field $file : param = undef;
    field $parser;
    ADJUST {
        unless ( $html xor $file ) {
            croak("You must supply 'html' or 'file' to the constructor");
        }
        my $target = $html ? \$html : $file;
        $parser = HTML::TokeParser->new($target);
    }

    method get_token (@args) {
        my $token = $parser->get_token(@args) or return;
        if ( my $factory_class = $TOKEN_CLASSES{ $token->[0] } ) {
            return $factory_class->new( token => $token );
        }
        else {
            # this should never happen
            croak("Cannot determine token class for token (@$token)");
        }
    }

    method get_tag (@args) {
        my $token = $parser->get_tag(@args) or return;

        # for some reason, HTML::Parser strips the leading letter if we
        # fetch tags directly
        my $is_start = $token->[0] !~ /^\//;
        unshift @$token => $is_start ? 'S' : 'E';
        return $is_start
          ? HTML::TokeParser::Corinna::Token::Tag::Start->new( token => $token )
          : HTML::TokeParser::Corinna::Token::Tag::End->new( token => $token );
    }

    method peek ( $count = 1 ) {
        unless ( $count =~ /^\d+$/ ) {
            croak("Argument to peek() must be a positive integer, not ($count)");
        }

        my $items = 0;
        my @tokens;
        while ( $items++ < $count && defined( my $token = $self->get_token ) ) {
            push @tokens, $token;
        }
        $parser->unget_token(@tokens);
        return \@tokens;
    }

    method unbroken_text ($bool) {
        $parser->unbroken_text($bool);
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

To simplify this, C<HTML::TokeParser::Corinna> allows the user ask more
intuitive (read: more self-documenting) questions about the tokens returned.

You can also rebuild some tags on the fly.  Frequently, the attributes
associated with start tags need to be altered, added to, or deleted.  This
functionality is built in.

=head1 CONTRUCTORS

=head2 C<new()>

    # from a string
    my $parser = HTML::TokeParser::Corinna->new( html => $html_string );

    # from a file
    my $parser = HTML::TokeParser::Corinna->new( file => $html_file );

=head1 PARSER METHODS

=head2 get_token

This method will return the next token that C<HTML::TokeParser::get_token()>
method would return.  However, it will be blessed into a class appropriate
which represents the token type.

=head2 get_tag

This method will return the next token that C<HTML::TokeParser::get_tag()>
method would return.  However, it will be blessed into either the
L<HTML::TokeParser::Corinna::Token::Tag::Start> or
L<HTML::TokeParser::Corinna::Token::Tag::End> class.

=head2 peek

    my $tokens = $parser->peek;      # get next token
    my $tokens = $parser->peek(3);   # get next three tokens

Returns an arrayref of tokens. Defaults to one token, but you can pass a
positive integer to specify the number of tokens you want returned. This will
allow you to I<peek> at the next few tokens without advancing the parser.

=head1 ACCESSORS

The following methods may be called on the token object which is returned,
not on the parser object.

=head2 Boolean Accessors

These accessors return true or false.

=over 4

=item * C<is_tag([$tag])>

Use this to determine if you have any tag.  An optional "tag type" may be
passed.  This will allow you to match if it's a I<particular> tag.  The
supplied tag is case-insensitive.

    if ( $token->is_tag ) { ... }

Optionally, you may pass a regular expression as an argument.

=item * C<is_start_tag([$tag])>

Use this to determine if you have a start tag.  An optional "tag type" may be
passed.  This will allow you to match if it's a I<particular> start tag.  The
supplied tag is case-insensitive.

    if ( $token->is_start_tag ) { ... }
    if ( $token->is_start_tag( 'font' ) ) { ... }

Optionally, you may pass a regular expression as an argument.  To match all
header (h1, h2, ... h6) tags:

    if ( $token->is_start_tag( qr/^h[123456]$/ ) ) { ... }

=item * C<is_end_tag([$tag])>

Use this to determine if you have an end tag.  An optional "tag type" may be
passed.  This will allow you to match if it's a I<particular> end tag.  The
supplied tag is case-insensitive.

When testing for an end tag, the forward slash on the tag is optional.

    while ( $token = $p->get_token ) {
      if ( $token->is_end_tag( 'form' ) ) { ... }
    }

Or:

    while ( $token = $p->get_token ) {
      if ( $token->is_end_tag( '/form' ) ) { ... }
    }

Optionally, you may pass a regular expression as an argument.

=item * C<is_text()>

Use this to determine if you have text.  Note that this is I<not> to be
confused with the C<return_text> (I<deprecated>) method described below!
C<is_text> will identify text that the user typically sees display in the Web
browser.

=item * C<is_comment()>

Are you still reading this?  Nobody reads POD.  Don't you know you're supposed
to go to CLPM, ask a question that's answered in the POD and get flamed?  It's
a rite of passage.

Really.

C<is_comment> is used to identify comments.  See the HTML::Parser documentation
for more information about comments.  There's more than you might think.

=item * C<is_declaration()>

This will match the DTD at the top of your HTML. (You I<do> use DTD's, don't
you?)

=item * C<is_process_instruction()>

Process Instructions are from XML.  This is very handy if you need to parse out
PHP and similar things with a parser.

Currently, there appear to be some problems with process instructions.  You can
override C<HTML::TokeParser::Corinna::Token::ProcessInstruction> if you need to.

=item * C<is_pi()>

This is a shorthand for C<is_process_instruction()>.

=back

=head2 Data Accessors

=over 4

=item * C<tag()>

Do you have a start tag or end tag?  This will return the type (lower case).
Note that this is not the same as the C<get_tag()> method on the actual
parser object.

=item * C<attr([$attribute])>

If you have a start tag, this will return a hash ref with the attribute names
as keys and the values as the values.

If you pass in an attribute name, it will return the value for just that
attribute.  

Returns false if the token is not a start tag.

=item * C<attrseq()>

For a start tag, this is an array reference with the sequence of the
attributes, if any.

Returns false if the token is not a start tag.

=item * C<to_string()>

This is the exact text of whatever the token is representing.

=item * C<token0()>

For processing instructions, this will return the token found immediately after
the opening tag.  Example:  For <?php, "php" will be the start of the returned
string.

Note that process instruction handling appears to be incomplete in
C<HTML::TokeParser>.

Returns false if the token is not a process instruction.

=back

=head1 MUTATORS

The C<delete_attr()> and C<set_attr()> methods allow the programmer to rewrite
start tag attributes on the fly.  It should be noted that bad HTML will be
"corrected" by this.  Specifically, the new tag will have all attributes
lower-cased with the values properly quoted.

Self-closing tags (e.g. E<lt>hr /E<gt>) are also handled correctly.  Some older
browsers require a space prior to the final slash in a self-closed tag.  If
such a space is detected in the original HTML, it will be preserved.

Calling a mutator on an token type that does not support that property is a
no-op.  For example:

    if ($token->is_comment) {
       $token->set_attr(foo => 'bar'); # does nothing
    }

=over 4

=item * C<delete_attr($name)>

This method attempts to delete the attribute specified.  It will silently fail
if called on anything other than a start tag.  The argument is
case-insensitive, but must otherwise be an exact match of the attribute you are
attempting to delete.  If the attribute is not found, the method will return
without changing the tag.

    # <body bgcolor="#FFFFFF">
    $token->delete_attr('bgcolor');
    print $token->to_string;
    # <body>
 
After this method is called, if successful, the C<to_string()>, C<attr()>
and C<attrseq()> methods will all return updated results.

=item * C<set_attr($name,$value)>

This method will set the value of an attribute.  If the attribute is not found,
then C<attrseq()> will have the new attribute listed at the end.

    # <p>
    $token->set_attr(class => 'some_class');
    print $token->to_string;
    # <p class="some_class">

    # <body bgcolor="#FFFFFF">
    $token->set_attr('bgcolor','red');
    print $token->to_string;
    # <body bgcolor="red">

After this method is called, if successful, the C<to_string()>, C<attr()>
and C<attrseq()> methods will all return updated results.

=item * C<set_attr($hashref)>

Under the premise that C<set_> methods should accept what their corresponding
accessor methods emit, the following works:

    $tag->set_attr($tag->attr);

Theoretically that's a no-op and for purposes of rendering HTML, it should be.
However, internally this calls C<$tag-E<gt>rewrite_tag>, so see that method to
understand how this may affect you.

Of course, this is useless if you want to actually change the attributes, so you
can do this:

    my $attrs = {
      class  => 'headline',
      valign => 'top'
    };
    $token->set_attr($attrs) 
      if $token->is_start_tag('td') &&  $token->attr('class') eq 'stories';

=item * C<rewrite_tag()>

This method rewrites the tag.  The tag name and the name of all attributes will
be lower-cased.  Values that are not quoted with double quotes will be.  This
may be called on both start or end tags.  Note that both C<set_attr()> and
C<delete_attr()> call this method prior to returning.

If called on a token that is not a tag, it simply returns.  Regardless of how
it is called, it returns the token.

    # <body alink=#0000ff BGCOLOR=#ffffff class='none'>
    $token->rewrite_tag;
    print $token->to_string;
    # <body alink="#0000ff" bgcolor="#ffffff" class="none">

A quick cleanup of sloppy HTML is now the following:

    my $parser = HTML::TokeParser::Corinna->new( string => $ugly_html );
    while (my $token = $parser->get_token) {
        $token->rewrite_tag;
        print $token->to_string;
    }
   
=back

=head1 PARSER VERSUS TOKENS 

The parser returns instances of tokens. You cannot call parser methods on
them.

=head1 EXAMPLES

=head2 Finding comments

For some strange reason, your Pointy-Haired Boss (PHB) is convinced that the
graphics department is making fun of him by embedding rude things about him in
HTML comments.  You need to get all HTML comments from the HTML.

    use HTML::TokeParser::Corinna;
   
    my @html_docs = glob( "*.html" );
   
    open my $pbh, '>', phbreport.txt" or die "Cannot open phbreport for writing: $!";
   
    foreach my $doc ( @html_docs ) {
        print "Processing $doc\n";
        my $p = HTML::TokeParser::Corinna->new( file => $doc );
        while ( my $token = $p->get_token ) {
            next unless $token->is_comment;
            print {$pbh} $token->to_string, "\n";
        }
    }
   
    close $phb;

=head2 Stripping Comments

Uh oh.  Turns out that your PBH was right for a change.  Many of the comments
in the HTML weren't very polite.  Since your entire graphics department was
just fired, it falls on you need to strip those comments from the HTML.

    use HTML::TokeParser::Corinna;
   
    my $new_folder = 'no_comment/';
    my @html_docs  = glob( "*.html" );
   
    foreach my $doc ( @html_docs ) {
        print "Processing $doc\n";
        my $new_file = "$new_folder$doc";
   
        open my $phb, '>', $new_file or die "Cannot open $new_file for writing: $!";
   
        my $p = HTML::TokeParser::Corinna->new( file => $doc );
        while ( my $token = $p->get_token ) {
            next if $token->is_comment;
            print {$phb} $token->to_string;
        }
        close $phb;
    }

=head2 Changing form tags

Your company was foo.com and now is bar.com.  Unfortunately, whoever wrote your
HTML decided to hardcode "http://www.foo.com/" into the C<action> attribute of
the form tags.  You need to change it to "http://www.bar.com/".

    use HTML::TokeParser::Corinna;
   
    my $new_folder = 'new_html/';
    my @html_docs  = glob( "*.html" );
   
    foreach my $doc ( @html_docs ) {
        print "Processing $doc\n";
        my $new_file = "$new_folder$doc";
   
        open my $fh, '>', $new_file or die "Cannot open $new_file for writing: $!";
   
        my $p = HTML::TokeParser::Corinna->new( html => $doc );
        while ( my $token = $p->get_token ) {
            if ( $token->is_start_tag('form') ) {
                my $action = $token->attr(action);
                $action =~ s/www\.foo\.com/www.bar.com/;
                $token->set_attr('action', $action);
            }
            print {$fh} $token->to_string;
        }
        close {$fh};
    }

=head1 CAVEATS

C<HTML::Parser> processes text in 512 byte chunks.  This sometimes will cause
strange behavior and cause text to be broken into more than one token.  You
can suppress this behavior with the following command:

    $p->unbroken_text( [$bool] );

See the C<HTML::Parser> documentation and
http://www.perlmonks.org/index.pl?node_id=230667 for more information.

=head1 BUGS

There are no known bugs, but that's no guarantee.

=head1 SEE ALSO

L<HTML::TokeParser::Corinna::Token>

L<HTML::TokeParser::Corinna::Token::Tag>

L<HTML::TokeParser::Corinna::Token::Text>

L<HTML::TokeParser::Corinna::Token::Comment>

L<HTML::TokeParser::Corinna::Token::Declaration>

L<HTML::TokeParser::Corinna::Token::ProcessInstruction>

=head1 COPYRIGHT

Copyright (c) 2022 by Curtis "Ovid" Poe.  All rights reserved.  This program is
free software; you may redistribute it and/or modify it under the same terms as
Perl itself

=cut
