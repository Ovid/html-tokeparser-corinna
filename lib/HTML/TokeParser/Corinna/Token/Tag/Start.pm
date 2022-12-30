use experimental 'class';
class HTML::TokeParser::Corinna::Token::Tag::Start : isa(HTML::TokeParser::Corinna::Token::Tag) {
    use HTML::Entities qw/encode_entities/;
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';

    # ["S",  $tag, $attr, $attrseq, $text]
    field $token : param;
    field $tag       = $token->[1];
    field $attr      = $token->[2];
    field $attrseq   = $token->[3];
    field $to_string = $token->[4];

    method tag {$tag}

    method attr ( $name = undef ) {
        return $name ? $attr->{ lc $name } : $attr;
    }

    method attrseq   {$attrseq}
    method to_string {$to_string}

    method set_attr ( $name, $value ) {
        $name = lc $name;
        unless ( exists $attr->{$name} ) {
            push @$attrseq => $name;
        }
        $attr->{$name} = $value;
        $self->rewrite_tag;
    }

    method rewrite_tag {

        # capture the final slash if the tag is self-closing
        my ($self_closing) = $self->to_string =~ m{(\s?/)>$};
        $self_closing ||= '';

        my $tag = '';
        foreach (@$attrseq) {
            next if $_ eq '/';    # is this a bug in HTML::TokeParser?
            $tag .= sprintf qq{ %s="%s"} => $_, encode_entities( $attr->{$_} );
        }
        $tag = sprintf '<%s%s%s>', $self->tag, $tag, $self_closing;
        $to_string = $tag;
    }

    method delete_attr ($name) {
        $name = lc $name;
        return unless exists $attr->{$name};
        delete $attr->{$name};
        my $attrseq = $self->attrseq;
        @$attrseq = grep { $_ ne $name } @$attrseq;
        $self->rewrite_tag;
    }

    method is_start_tag ( $tag = undef ) {
        return true unless defined $tag;
        return lc $tag eq lc $self->tag;
    }
}

1;
__END__

=head1 NAME

HTML::TokeParser::Corinna::Token::Tag::Start - Token.pm "start tag" class.

=head1 SYNOPSIS

     use HTML::TokeParser::Corinna;
     my $p = HTML::TokeParser::Corinna->new( file => $somefile );
    
     while ( my $token = $p->get_token ) {
         # This prints all text in an HTML doc (i.e., it strips the HTML)
         next unless $token->is_text;
         print $token->to_string;
     }

=head1 DESCRIPTION

This class does most of the heavy lifting for C<HTML::TokeParser::Corinna>.  See
the C<HTML::TokeParser::Corinna> docs for details.

=head1 OVERRIDDEN METHODS

=over 4

=item * to_string

=item * delete_attr

=item * tag

=item * token0

=item * is_start_tag

=item * is_tag

=item * attr

=item * attrseq

=item * tag

=item * text

=item * rewrite_tag

=item * set_attr

=back

=cut

