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
to [HTML::TokeParser::Simple](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ASimple), but the latter is a drop-in replacement for
`HTML::TokeParser` and this module is not (it can't be because we're not
blessing array references).

To simplify this, `HTML::TokeParser::Corinna` allows the user ask more
intuitive (read: more self-documenting) questions about the tokens returned.

Note that all objects in this module are immutable. You can rebuild some tags
on the fly, but any code that changes a token returns a new instance.

# CONTRUCTORS

## `new()`

    # from a string
    my $parser = HTML::TokeParser::Corinna->new( html => $html_string );

    # from a file
    my $parser = HTML::TokeParser::Corinna->new( file => $html_file );

# PARSER METHODS

## get\_token

This method will return the next token that `HTML::TokeParser::get_token()`
method would return.  However, it will be blessed into a class appropriate
which represents the token type.

## get\_tag

This method will return the next token that `HTML::TokeParser::get_tag()`
method would return.  However, it will be blessed into either the
[HTML::TokeParser::Corinna::Token::Tag::Start](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3ATag%3A%3AStart) or
[HTML::TokeParser::Corinna::Token::Tag::End](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3ATag%3A%3AEnd) class.

## peek

    my $tokens = $parser->peek;      # get next token
    my $tokens = $parser->peek(3);   # get next three tokens

Returns an arrayref of tokens. Defaults to one token, but you can pass a
positive integer to specify the number of tokens you want returned. This will
allow you to _peek_ at the next few tokens without advancing the parser.

# ACCESSORS

The following methods may be called on the token object which is returned,
not on the parser object.

## Boolean Accessors

These accessors return true or false.

- `is_tag([$tag])`

    Use this to determine if you have any tag.  An optional "tag type" may be
    passed.  This will allow you to match if it's a _particular_ tag.  The
    supplied tag is case-insensitive.

        if ( $token->is_tag ) { ... }

    Optionally, you may pass a regular expression as an argument.

- `is_start_tag([$tag])`

    Use this to determine if you have a start tag.  An optional "tag type" may be
    passed.  This will allow you to match if it's a _particular_ start tag.  The
    supplied tag is case-insensitive.

        if ( $token->is_start_tag ) { ... }
        if ( $token->is_start_tag( 'font' ) ) { ... }

    Optionally, you may pass a regular expression as an argument.  To match all
    header (h1, h2, ... h6) tags:

        if ( $token->is_start_tag( qr/^h[123456]$/ ) ) { ... }

- `is_end_tag([$tag])`

    Use this to determine if you have an end tag.  An optional "tag type" may be
    passed.  This will allow you to match if it's a _particular_ end tag.  The
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

- `is_text()`

    Use this to determine if you have text.  Note that this is _not_ to be
    confused with the `return_text` (_deprecated_) method described below!
    `is_text` will identify text that the user typically sees display in the Web
    browser.

- `is_comment()`

    Are you still reading this?  Nobody reads POD.  Don't you know you're supposed
    to go to CLPM, ask a question that's answered in the POD and get flamed?  It's
    a rite of passage.

    Really.

    `is_comment` is used to identify comments.  See the HTML::Parser documentation
    for more information about comments.  There's more than you might think.

- `is_declaration()`

    This will match the DTD at the top of your HTML. (You _do_ use DTD's, don't
    you?)

- `is_process_instruction()`

    Process Instructions are from XML.  This is very handy if you need to parse out
    PHP and similar things with a parser.

    Currently, there appear to be some problems with process instructions.  You can
    override `HTML::TokeParser::Corinna::Token::ProcessInstruction` if you need to.

- `is_pi()`

    This is a shorthand for `is_process_instruction()`.

## Data Accessors

- `tag()`

    Do you have a start tag or end tag?  This will return the type (lower case).
    Note that this is not the same as the `get_tag()` method on the actual
    parser object.

- `attr([$attribute])`

    If you have a start tag, this will return a hash ref with the attribute names
    as keys and the values as the values.

    If you pass in an attribute name, it will return the value for just that
    attribute.  

    Returns false if the token is not a start tag.

- `attrseq()`

    For a start tag, this is an array reference with the sequence of the
    attributes, if any.

    Returns false if the token is not a start tag.

- `to_string()`

    This is the exact text of whatever the token is representing.

- `token0()`

    For processing instructions, this will return the token found immediately after
    the opening tag.  Example:  For &lt;?php, "php" will be the start of the returned
    string.

    Note that process instruction handling appears to be incomplete in
    `HTML::TokeParser`.

    Returns false if the token is not a process instruction.

# MUTATORS

The `delete_attrs()` and `set_attrs()` methods allow the programmer to rewrite
start tag attributes on the fly.  It should be noted that bad HTML will be
"corrected" by this.  Specifically, the new tag will have all attributes
lower-cased with the values properly quoted.

Self-closing tags (e.g. &lt;hr />) are also handled correctly.  Some older
browsers require a space prior to the final slash in a self-closed tag.  If
such a space is detected in the original HTML, it will be preserved.

Because `HTML::TokeParser::Corinna` objects are immutable, mutators actually
return new instances of these objects. This prevents strange "action at a distance"
when you pass a token to a subroutine and it alters the token in unsuspecting ways. Thus, you'll want
to do this:

    my $new_token = $token->delete_attrs(@attribute_names);
    # or
    $token = $token->delete_attrs(@attribute_names);

Calling a mutator in void context will throw an
`HTML::TokeParser::Corinna::Exception::VoidContext` exception.

- `delete_attrs(@attribute_names)`

    This method attempts to delete the attribute specified. This is only available
    for start tags.  The argument is case-insensitive, but must otherwise be an
    exact match of the attribute you are attempting to delete.  If the attribute
    is not found, the method will return without changing the tag.

           if ( $token->is_start_tag('body') ) {
               # <body bgcolor="#FFFFFF">
               my $new_token = $token->delete_attrs('bgcolor');
               print $new_token->to_string;
               # <body>
           }
        

- `set_attrs(%kv_pairs)`

    This method will set the value of attributes for start tags. If the attribute
    is not found, then `attrseq()` will have the new attribute listed at the end.

        # <p>
        $token = $token->set_attrs(class => 'some_class');
        print $token->to_string;
        # <p class="some_class">

        # <body bgcolor="#FFFFFF">
        $token = $token->set_attrs('bgcolor','red');
        print $token->to_string;
        # <body bgcolor="red">

    After this method is called, if successful, the `to_string()`, `attr()`
    and `attrseq()` methods will all return updated results.

- `normalize_tag()`

    This method rewrites start and end tags. The tag name and the name of all attributes will
    be lower-cased.  Values that are not quoted with double quotes will be.  This
    may be called on both start or end tags.  Note that both `set_attrs()` and
    `delete_attrs()` call this method prior to returning.

    If called on a token that is not a tag, it simply returns.  Regardless of how
    it is called, it returns the token.

        # <body alink=#0000ff BGCOLOR=#ffffff class='none'>
        $token = $token->rewrite_tag;
        print $token->to_string;
        # <body alink="#0000ff" bgcolor="#ffffff" class="none">

    A quick cleanup of sloppy HTML is now the following:

         my $parser = HTML::TokeParser::Corinna->new( string => $ugly_html );
         while (my $token = $parser->get_token) {
             $token = $token->rewrite_tag;
             print $token->to_string;
         }
        

# PARSER VERSUS TOKENS 

The parser returns instances of tokens. You cannot call parser methods on
them.

# EXAMPLES

## Finding comments

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

## Stripping Comments

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

## Changing form tags

Your company was foo.com and now is bar.com.  Unfortunately, whoever wrote your
HTML decided to hardcode "http://www.foo.com/" into the `action` attribute of
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
                 $token = $token->set_attrs('action', $action);
             }
             print {$fh} $token->to_string;
         }
         close {$fh};
     }

# CAVEATS

`HTML::Parser` processes text in 512 byte chunks.  This sometimes will cause
strange behavior and cause text to be broken into more than one token.  You
can suppress this behavior with the following command:

    $p->unbroken_text( [$bool] );

See the `HTML::Parser` documentation and
http://www.perlmonks.org/index.pl?node\_id=230667 for more information.

# BUGS

There are no known bugs, but that's no guarantee.

# SEE ALSO

[HTML::TokeParser::Corinna::Token](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken)

[HTML::TokeParser::Corinna::Token::Tag](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3ATag)

[HTML::TokeParser::Corinna::Token::Text](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3AText)

[HTML::TokeParser::Corinna::Token::Comment](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3AComment)

[HTML::TokeParser::Corinna::Token::Declaration](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3ADeclaration)

[HTML::TokeParser::Corinna::Token::ProcessInstruction](https://metacpan.org/pod/HTML%3A%3ATokeParser%3A%3ACorinna%3A%3AToken%3A%3AProcessInstruction)

# COPYRIGHT

Copyright (c) 2023 by Curtis "Ovid" Poe.  All rights reserved.  This program is
free software; you may redistribute it and/or modify it under the same terms as
Perl itself
