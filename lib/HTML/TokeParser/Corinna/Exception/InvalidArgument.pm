use experimental 'class';
class HTML::TokeParser::Corinna::Exception::InvalidArguemnt : isa(HTML::TokeParser::Corinna::Exception) {
    field $method : param;

    method error ()  {"Invalid arguemnts passed to $method"}
    method method () {$method}
}

1;
