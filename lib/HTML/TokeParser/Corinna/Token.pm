use experimental 'class';

class HTML::TokeParser::Corinna::Token {
    field $token :param;

    method to_string              {$token->[1]}
    method _get_token             {$token}
    method is_tag                 {}
    method is_start_tag           {}
    method is_end_tag             {}
    method is_text                {}
    method is_comment             {}
    method is_declaration         {}
    method is_pi                  {}
    method is_process_instruction {}
    method rewrite_tag            {}
    method delete_attr            {}
    method set_attr               {}
    method tag                    {}
    method attr                   {}
    method attrseq                {}
    method token0                 {}
}

1;
