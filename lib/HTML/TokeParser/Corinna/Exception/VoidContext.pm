use experimental 'class';
use HTML::TokeParser::Corinna::Exception;
class HTML::TokeParser::Corinna::Exception::VoidContext : isa(HTML::TokeParser::Corinna::Exception) {
    field $method : param;
    field $message = "Method '$method' must not be called in void context";

    method method () {$method}

    method to_string () {
        my $stack_trace = $self->stack_trace;
        return "Error: $message\n\nStack Trace:\n$stack_trace";
    }
}

1;
