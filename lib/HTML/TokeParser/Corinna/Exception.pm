use experimental 'class';
class HTML::TokeParser::Corinna::Exception {

    # overloading does not yet work
    #use overload '""' => 'to_string', fallback => 1;
    use Devel::StackTrace;

    field $stack_trace = Devel::StackTrace->new->as_string;

    method stack_trace () {$stack_trace}

    method to_string () {
        return "Error: An unexpected error occurred.\n\nStack Trace:\n$stack_trace";
    }
}

1;
