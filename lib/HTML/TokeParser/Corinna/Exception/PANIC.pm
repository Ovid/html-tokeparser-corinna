use experimental 'class';
class HTML::TokeParser::Corinna::Exception::PANIC : isa(HTML::TokeParser::Corinna::Exception) {
    field $method : param;

    method error ()  {"An error that should never occur has occurred."}
    method method () {$method}
}

1;
