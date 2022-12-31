use experimental 'class';
class HTML::TokeParser::Corinna::Exception {

    # overloading does not yet work
    # use overload '""' => 'to_string', fallback => 1;
    use Devel::StackTrace;

    field $message : param = undef;
    field $stack_trace = Devel::StackTrace->new->as_string;

    method error ()       {"An unexpected error occurred"}
    method message ()     {$message}
    method stack_trace () {$stack_trace}

    method to_string () {
        my $erorr = $self->error;
        if ( my $message = $self->message ) {
            $error .= "\n$message";
        }
        my $stack_trace = $self->stack_trace;
        return "Error: $message\n\nStack Trace:\n$stack_trace";
    }
}

1;
