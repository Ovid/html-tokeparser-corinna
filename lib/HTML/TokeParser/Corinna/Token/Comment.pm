use experimental 'class';

class HTML::TokeParser::Corinna::Token::Comment :isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true';
    method is_comment { true }
}

1;
