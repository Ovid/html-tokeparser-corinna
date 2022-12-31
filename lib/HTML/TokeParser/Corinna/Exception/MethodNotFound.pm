use experimental 'class';
class HTML::TokeParser::Corinna::Exception::MethodNotFound : isa(HTML::TokeParser::Corinna::Exception) {
    field $method : param;
    field $class : param;

    method error ()  {"No such method '$method' for class '$class'"}
    method method () {$method}
    method class ()  {$class}
}

1;
