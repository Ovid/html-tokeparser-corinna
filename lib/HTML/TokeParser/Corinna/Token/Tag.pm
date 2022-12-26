use experimental 'class';
class HTML::TokeParser::Corinna::Token::Tag :isa(HTML::TokeParser::Corinna::Token) {
    field $attrseq //= [];
    field $attr    //= {};
    method attrseq           { $attrseq }
    method attr (@)          { $attr }
    method to_string         { $self->_get_token->[2] }
    method tag               { lc $self->_get_token->[1] }
    method is_tag            {1}
    method _set_text ($text) { $self->_get_token->[2] = $text }
    method rewrite_tag       {}
}

1;
