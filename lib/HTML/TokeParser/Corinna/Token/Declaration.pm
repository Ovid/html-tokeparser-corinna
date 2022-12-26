use experimental 'class';
class  HTML::TokeParser::Corinna::Token::Declaration :isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true';
    method is_declaration { true }
}

1;
