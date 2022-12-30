use experimental 'class';
use HTML::TokeParser::Corinna;
class HTML::TokeParser::Corinna::Token::Tag::Start : isa(HTML::TokeParser::Corinna::Token::Tag) {
    use HTML::Entities qw/encode_entities/;
    no warnings 'experimental::builtin';
    use builtin 'true', 'false';
    use HTML::TokeParser::Corinna::Utils 'throw';

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
        if ( !defined wantarray ) {
            throw( VoidContext => method => 'set_attr' );
        }
        $name = lc $name;
        my $sequence   = [ $attrseq->@* ];
        my $attributes = { $attr->%* };
        unless ( exists $attributes->{$name} ) {
            push @$sequence => $name;
        }
        $attributes->{$name} = $value;
        return $self->_rewrite_tag( $sequence, $attributes );
    }

    method delete_attr ($name) {
        if ( !defined wantarray ) {
            throw( VoidContext => method => 'delete_attr' );
        }
        $name = lc $name;
        my $sequence   = [ $attrseq->@* ];
        my $attributes = { $attr->%* };
        if ( exists $attributes->{$name} ) {
            delete $attributes->{$name};
            $sequence->@* = grep { $_ ne $name } $sequence->@*;
        }
        return $self->_rewrite_tag( $sequence, $attributes );
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

=item * delete_attr

=item * tag

=item * token0

=item * is_start_tag

=item * is_tag

=item * attr

=item * attrseq

=item * tag

=item * text

=item * set_attr

=back

=cut

