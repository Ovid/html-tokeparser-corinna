use experimental 'class';
class HTML::TokeParser::Corinna::Token::Tag :isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    method attrseq           { [] }
    method attr (@)          { {} }
    method to_string         { $self->_get_token->[2] }
    method tag               { lc $self->_get_token->[1] }
    method is_tag            {true}
    method _set_text ($text) { $self->_get_token->[2] = $text }
    method rewrite_tag       {}
}

1;
