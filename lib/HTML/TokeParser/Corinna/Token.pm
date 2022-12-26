use experimental 'class';

class HTML::TokeParser::Corinna::Token {
    no warnings 'experimental::builtin';
    use builtin 'false';
    use Perl::Tidy;
    field $token :param;

    method to_string              {$token->[1]}
    method _get_token             {$token}
    method is_tag                 {false}
    method is_start_tag           {false}
    method is_end_tag             {false}
    method is_text                {false}
    method is_comment             {false}
    method is_declaration         {false}
    method is_pi                  {false}
    method is_process_instruction {false}
    method rewrite_tag            {}
    method delete_attr            {}
    method set_attr               {}
    method tag                    {}
    method attr                   {}
    method attrseq                {}
    method token0                 {}
}

1;
