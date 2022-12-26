use experimental 'class';

class HTML::TokeParser::Corinna::Token::Tag::End :isa(HTML::TokeParser::Corinna::Token::Tag) {
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    method is_end_tag ($tag=undef) {
        return true unless defined $tag;
        return lc $tag eq lc $self->tag;
    }
    method rewrite_tag { 
        my $tag = $self->tag;
        $self->_get_token->[2] = sprintf "</%s>" => $tag;
    }
}

1;
