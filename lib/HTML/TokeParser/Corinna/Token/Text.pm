use experimental 'class';

class HTML::TokeParser::Corinna::Token::Text : isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true';
    method is_text { true }
}

1;
