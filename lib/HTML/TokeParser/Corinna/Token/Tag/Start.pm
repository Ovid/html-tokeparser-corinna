use experimental 'class';
use HTML::TokeParser::Corinna::Token::Tag;
class HTML::TokeParser::Corinna::Token::Tag::Start : isa(HTML::TokeParser::Corinna::Token::Tag) {
    use HTML::TokeParser::Corinna::Policy;
    use HTML::Entities qw/encode_entities/;

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

    method set_attrs (@pairs) {
        if ( !defined wantarray ) {
            throw( VoidContext => method => 'set_attrs' );
        }
        unless ( !( @pairs % 2 ) ) {
            throw(
                'InvalidArgument',
                method  => 'set_attrs',
                message => 'Arguments must be an even-sized list of key/value pairs',
            );
        }
        my $sequence   = [ $attrseq->@* ];
        my $attributes = { $attr->%* };
        while ( my ( $attribute, $value ) = splice @pairs, 0, 2 ) {
            $attribute = lc $attribute;
            unless ( exists $attributes->{$attribute} ) {
                push @$sequence => $attribute;
            }
            $attributes->{$attribute} = $value;
        }
        return $self->_rewrite_tag( $sequence, $attributes );
    }

    method delete_attrs (@attributes) {
        if ( !defined wantarray ) {
            throw( VoidContext => method => 'delete_attrs' );
        }
        my $sequence   = [ $attrseq->@* ];
        my $attributes = { $attr->%* };
        foreach my $attribute (@attributes) {
            $attribute = lc $attribute;
            if ( exists $attributes->{$attribute} ) {
                delete $attributes->{$attribute};
                $sequence->@* = grep { $_ ne $attribute } $sequence->@*;
            }
        }
        return $self->_rewrite_tag( $sequence, $attributes );
    }

    method delete_all_attrs () {
        return $self->delete_attrs($attrseq->@*);
    }

    method is_start_tag ( $tag = undef ) {
        return true unless defined $tag;
        return lc $tag eq lc $self->tag;
    }

    method normalize_tag () {
        if ( !defined wantarray ) {
            throw( VoidContext => method => 'normalize_tag' );
        }
        return $self->_rewrite_tag( $attrseq, $attr );
    }

    method _rewrite_tag ( $sequence, $attributes ) {

        # capture the final slash if the tag is self-closing
        my ($self_closing) = $to_string =~ m{(\s?/)>$};
        $self_closing ||= '';

        my $new_tag = '';
        foreach (@$sequence) {
            next if $_ eq '/';    # is this a bug in HTML::TokeParser?
            $new_tag .= sprintf qq{ %s="%s"} => lc, encode_entities( $attributes->{$_} );
        }
        $new_tag = sprintf '<%s%s%s>', $tag, $new_tag, $self_closing;

        return (ref $self)->new( token => [ 'S', $tag, $attributes, $sequence, $new_tag ] );
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

=item * delete_attrs

=item * tag

=item * token0

=item * is_start_tag

=item * is_tag

=item * attr

=item * attrseq

=item * tag

=item * text

=item * set_attrs

=back

=cut

