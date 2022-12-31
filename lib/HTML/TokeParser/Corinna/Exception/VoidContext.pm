use experimental 'class';
use HTML::TokeParser::Corinna::Exception;
class HTML::TokeParser::Corinna::Exception::VoidContext : isa(HTML::TokeParser::Corinna::Exception) {
    field $method : param;

    method error ()  {"Method '$method' must not be called in void context"}
    method method () {$method}
}

1;
