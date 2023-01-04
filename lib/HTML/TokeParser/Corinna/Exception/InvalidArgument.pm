use experimental 'class';
use HTML::TokeParser::Corinna::Exception;
class HTML::TokeParser::Corinna::Exception::InvalidArgument : isa(HTML::TokeParser::Corinna::Exception) {
    use HTML::TokeParser::Corinna::Policy;
    field $method : param;

    method error ()  {"Invalid arguemnts passed to $method"}
    method method () {$method}
}

1;
