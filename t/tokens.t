#!/usr/bin/env perl

use v5.37.8;
use lib 'lib';
use Test::Most;

use HTML::TokeParser::Corinna;

subtest 'text tokens' => sub {
    ok my $token = HTML::TokeParser::Corinna::Token::Text->new( token => [ 'T', 'This is my text' ] ),
      'We should be able to create a text object';
    is $token->to_string, 'This is my text',
      '... and we should be able to get the string representation of the token';
    ok $token->is_text, '... and it should declare itself a text token';

    foreach my $method (
        qw/
        is_tag is_start_tag is_end_tag is_comment is_declaration is_pi
        is_process_instruction
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
};

subtest 'comment tokens' => sub {
    ok my $token = HTML::TokeParser::Corinna::Token::Comment->new( token => [ 'C', '<!-- this is a comment -->' ] ),
      'We should be able to create a comment object';
    is $token->to_string, '<!-- this is a comment -->',
      '... and we should be able to get the string representation of the comment';
    ok $token->is_comment, '... and it should declare itself a comment token';

    foreach my $method (
        qw/
        is_tag is_start_tag is_end_tag is_text is_declaration is_pi
        is_process_instruction
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
};

subtest 'declaration tokens' => sub {
    my $declaration = <<~'END';
    <!DOCTYPE html PUBLIC
      "-//W3C//DTD XHTML 1.0 Transitional//EN"
      "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
    END
    ok my $token = HTML::TokeParser::Corinna::Token::Declaration->new( token => [ 'D', $declaration ] ),
      'We should be able to create a declaration object';
    is $token->to_string, $declaration,
      '... and we should be able to get the string representation of the declaration';
    ok $token->is_declaration, '... and it should declare itself a declaration token';

    foreach my $method (
        qw/
        is_tag is_start_tag is_end_tag is_text is_comment is_pi
        is_process_instruction
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
};

subtest 'process instruction tokens' => sub {
    my $token0 = 'xml-stylesheet type="text/xsl" href="style.xsl"';
    my $pi     = "<?$token0?>";
    ok my $token = HTML::TokeParser::Corinna::Token::ProcessInstruction->new( token => [ 'PR', $token0, $pi ] ),
      'We should be able to create a process instruction object';
    is $token->to_string, $pi,
      '... and we should be able to get the string representation of the process instruction';
    ok $token->is_process_instruction, '... and it should declare itself a process instruction token';
    ok $token->is_pi,                  '... and it should declare itself a process instruction token';
    is $token->token0, $token0, '... and the token should also be returned';

    foreach my $method (
        qw/
        is_tag is_start_tag is_end_tag is_text is_comment is_declaration
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
};

subtest 'end tag tokens' => sub {

    ok my $token
      = HTML::TokeParser::Corinna::Token::Tag::End->new( token => [ 'E', 'p', '</p>' ] ),
      'We should be able to create a tag object';
    is $token->to_string, '</p>',
      '... and we should be able to get the string representation of the tag';
    is $token->tag, 'p', '... and we should be able to fetch the tag';
    ok $token->is_tag,     '... and it should identify itself as a tag';
    ok $token->is_end_tag, '... and even as an end tag';

    foreach my $method (
        qw/
        is_start_tag is_text is_comment is_declaration
        is_pi is_process_instruction
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
};

subtest 'start tag tokens' => sub {

    my $tag      = 'article';
    my $full_tag = '<article id="electric-cars" data-columns="3">';
    my $attrseq  = [qw/id data-columns/];
    my $attr     = {
        id             => 'electric-cars',
        'data-columns' => 3,
    };

    # abstract class
    ok my $token
      = HTML::TokeParser::Corinna::Token::Tag::Start->new( token => [ 'S', $tag, $attr, $attrseq, $full_tag ] ),
      'We should be able to create a tag object';
    is $token->to_string, $full_tag,
      '... and we should be able to get the string representation of the tag';
    is $token->tag, $tag, '... and we should be able to fetch the tag';
    ok $token->is_tag,       '... and it should identify itself as a tag';
    ok $token->is_start_tag, '... and even as an end tag';
    is_deeply $token->attrseq, $attrseq, 'We should be able to get the attribute sequence';
    is_deeply $token->attr,    $attr,    '... and the attributes as a hashref';

    foreach my $method (
        qw/
        is_end_tag is_text is_comment is_declaration
        is_pi is_process_instruction
        /
      )
    {
        ok !$token->$method,
          "We should be able to call \$object->$method and have it return false";
    }
    throws_ok { $token->set_attr( foo => 'bar' ) } 'HTML::TokeParser::Corinna::Exception::VoidContext', 'We cannot call setters in void context';
    throws_ok { $token->normalize_tag } 'HTML::TokeParser::Corinna::Exception::VoidContext', 'We cannot call normalize_tag in void context';
    ok my $new_token = $token->set_attr( id => 'bicycles' ), 'We should be able to set attributes';
    is $token->to_string,     '<article id="electric-cars" data-columns="3">', '... and the token is unchanged';
    is $new_token->to_string, '<article id="bicycles" data-columns="3">',      '... but we get a new token with the new data';
    ok $new_token = $new_token->set_attr( foo => 'bar' ), 'We should be able to add attributes';
    is $new_token->to_string, '<article id="bicycles" data-columns="3" foo="bar">', '... and again get a new token with the new attributes';
};
done_testing;
