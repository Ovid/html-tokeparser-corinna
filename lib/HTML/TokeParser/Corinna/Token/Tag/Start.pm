use experimental 'class';
class HTML::TokeParser::Corinna::Token::Tag::Start :isa(HTML::TokeParser::Corinna::Token::Tag) {
    use HTML::Entities qw/encode_entities/;
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    method set_attr ($name, $value) {
        $name = lc $name;
        my $attr    = $self->attr;
        my $attrseq = $self->attrseq;
        unless (exists $attr->{$name}) {
            push @$attrseq => $name;
        }
        $attr->{$name} = $value;
        $self->rewrite_tag;
    }

    method rewrite_tag {
        my $attr    = $self->attr;
        my $attrseq = $self->attrseq;

        # capture the final slash if the tag is self-closing
        my ($self_closing) = $self->to_string =~ m{(\s?/)>$};
        $self_closing ||= '';
        
        my $tag = '';
        foreach ( @$attrseq ) {
            next if $_ eq '/'; # is this a bug in HTML::TokeParser?
            $tag .= sprintf qq{ %s="%s"} => $_, encode_entities($attr->{$_});
        }
        $tag = sprintf '<%s%s%s>', $self->tag, $tag, $self_closing;
        $self->_get_token->[4] = $tag;
    }

    method delete_attr ($name) {
        $name = lc $name;
        my $attr = $self->attr;
        return unless exists $attr->{$name};
        delete $attr->{$name};
        my $attrseq = $self->attrseq;
        @$attrseq = grep { $_ ne $name } @$attrseq;
        $self->rewrite_tag;
    }

    method attr ($name = undef) {
        my $attributes = $self->_get_token->[2];
        return $name ? $attributes->{lc $name} : $attributes;
    }

    method attrseq      { $self->_get_token->[3]  }
    method to_string    { $self->_get_token->[4] }
    method is_start_tag ($tag=undef) {
        return true unless defined $tag;
        return lc $tag eq lc $self->tag;
    }
}

1;
