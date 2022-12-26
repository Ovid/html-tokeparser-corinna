use experimental 'class';

class HTML::TokeParser::Corinna::Token::ProcessInstruction :isa(HTML::TokeParser::Corinna::Token) {
    method token0                 { $self->_get_token->[1] }
    method to_string              { $self->_get_token->[2] }
    method is_pi                  { 1 }
    method is_process_instruction { 1 }
}

1;
