use experimental 'class';

class HTML::TokeParser::Corinna::Token::Comment :isa(HTML::TokeParser::Corinna::Token) {
    method is_comment { 1 }
}

1;
