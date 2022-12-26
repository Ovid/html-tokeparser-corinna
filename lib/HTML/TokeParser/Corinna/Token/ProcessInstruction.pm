use experimental 'class';

class HTML::TokeParser::Corinna::Token::ProcessInstruction :isa(HTML::TokeParser::Corinna::Token) {
    no warnings 'experimental::builtin';
    use builtin 'true';
    method token0                 { $self->_get_token->[1] }
    method to_string              { $self->_get_token->[2] }
    method is_pi                  { true }
    method is_process_instruction { true }
}

1;
