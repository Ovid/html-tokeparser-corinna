#!/usr/bin/env perl

use lib 'lib';
use Test::Most;
use HTML::TokeParser::Corinna;

my $test_html = <<'END_HTML';
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
	<head>
		<!-- This is a comment -->
		<title>This is a title</title>
		<?php 
			print "<!-- this is generated by php -->";
		?>
	</head>
	<body alink="#0000ff" BGCOLOR="#ffffff">
		<h1>Do not edit this HTML lest the tests fail!!!</h1>
    <hr class="foo" />
    <hr class="bar"/>
	</body>
</html>
END_HTML

my $p = HTML::TokeParser::Corinna->new( html => $test_html );

my $token;
do { $token = $p->get_token } until $token->is_end_tag('head');
can_ok( $token, 'set_attr' );

do { $token = $p->get_token } until $token->is_start_tag('body');
can_ok( $token, 'set_attr' );
$token->set_attr( foo => 'bar' );
is(
    $token->to_string,
    '<body alink="#0000ff" bgcolor="#ffffff" foo="bar">',
    '... but a good token should set the new attribute'
);
$token->set_attr( bgcolor => 'white' );
is(
    $token->to_string,
    '<body alink="#0000ff" bgcolor="white" foo="bar">',
    '... or overwrite an existing one'
);

is_deeply( $token->attrseq, [qw{alink bgcolor foo}],
    '... and the attribute sequence should be updated' );
my $attr = {
    alink   => "#0000ff",
    bgcolor => "white",
    foo     => "bar"
};
is_deeply( $token->attr, $attr, '... as should the attributes themselves' );

can_ok( $token, 'delete_attr' );
$token->delete_attr('asdf');
is(
    $token->to_string,
    '<body alink="#0000ff" bgcolor="white" foo="bar">',
    '... and deleting a non-existent attribute should be a no-op'
);
$token->delete_attr('foo');
is(
    $token->to_string,
    '<body alink="#0000ff" bgcolor="white">',
    '... and deleting an existing one should succeed'
);
$token->set_attr( 'foo', 'bar' );
$token->delete_attr('FOO');
is(
    $token->to_string,
    '<body alink="#0000ff" bgcolor="white">',
    '... and deleting should be case-insensitive'
);

do { $token = $p->get_token } until $token->is_start_tag('h1');
is( $token->tag,, 'h1', 'Calling tag() should return the tag' );
ok( $token->is_start_tag,
    'Calling is_start_tag with a should succeed' );

do { $token = $p->get_token } until $token->is_start_tag('hr');
$token->set_attr( 'class', 'fribble' );
is(
    $token->to_string,
    '<hr class="fribble" />',
    'Setting attributes on self-closing tags should succeed'
);
$token->delete_attr('class');
is( $token->to_string, '<hr />', '... as should deleting them' );

do { $token = $p->get_token } until $token->is_start_tag('hr');
$token->set_attr( 'class', 'fribble' );
is(
    $token->to_string,
    '<hr class="fribble"/>',
    'Setting attributes on self-closing tags should succeed'
);
$token->delete_attr('class');
is( $token->to_string, '<hr/>', '... as should deleting them' );

can_ok( $token, 'rewrite_tag' );
my ( $html, $fixed_html ) = fetch_html();
my $parser   = HTML::TokeParser::Corinna->new( html => $html );
my $new_html = '';
while ( my $token = $parser->get_token ) {
    $token->rewrite_tag;
    $new_html .= $token->to_string;
}
eq_or_diff( $new_html, $fixed_html, '... and it should correctly rewrite all tags' );

$html   = '<span title="with &quot;kwotes&quot; inside">';
$parser = HTML::TokeParser::Corinna->new( html => $html );
my $span = $parser->get_tag('span');
is $span->to_string, $html,
  'We should be able to fetch tags with escaped attributes';
ok $span->rewrite_tag, '... and rewriting said tags should succeed';
is $span->to_string, $html, '... and the attributes should be properly escaped';

done_testing;

sub fetch_html {
    my $html = <<'    END_HTML';
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
	<HEAD>
		<!-- This is a comment -->
		<title>This is a title</title>
		<?php 
			print "<!-- this is generated by php -->";
		?>
	</head>
	<body alink=#0000ff BGCOLOR=#ffffff>
		<H1>Do not edit this HTML lest the tests fail!!!</H1>
        <hr class="foo" />
        <hr class='bar'/>
	</body>
</html>
    END_HTML

    my $fixed_html = <<'    END_HTML';
<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
<html>
	<head>
		<!-- This is a comment -->
		<title>This is a title</title>
		<?php 
			print "<!-- this is generated by php -->";
		?>
	</head>
	<body alink="#0000ff" bgcolor="#ffffff">
		<h1>Do not edit this HTML lest the tests fail!!!</h1>
        <hr class="foo" />
        <hr class="bar"/>
	</body>
</html>
    END_HTML
    return $html, $fixed_html;
}
