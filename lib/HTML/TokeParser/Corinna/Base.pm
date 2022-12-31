use experimental 'class';
class HTML::TokeParser::Corinna::Base {
    use HTML::TokeParser::Corinna::Policy;

    method AUTOLOAD {
        our $AUTOLOAD;

        my ( $class, $method ) = ( $AUTOLOAD =~ /^(.*)::(.*)$/ );
        return if $method eq 'DESTROY';
        throw(
            'MethodNotFound',
            method => $method,
            class  => $class,
        );
    }
}

1;
