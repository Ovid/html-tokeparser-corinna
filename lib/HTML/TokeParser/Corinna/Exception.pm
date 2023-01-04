use experimental 'class';
class HTML::TokeParser::Corinna::Exception {
    use overload '""' => 'to_string', fallback => 1;
    use Devel::StackTrace;

    field $message : param = undef;
    field $stack_trace = Devel::StackTrace->new->as_string;

    method error ()       {"An unexpected error occurred"}
    method message ()     {$message}
    method stack_trace () {$stack_trace}

    # XXX the `@` is needed in the signature because overload
    # passes additional arguments to the method, but we don't care
    # about those.
    method to_string (@) {
        my $error = $self->error;
        if ( my $message = $self->message ) {
            $error .= "\n$message";
        }
        my $stack_trace = $self->stack_trace;
        return "Error: $error\n\nStack Trace:\n$stack_trace";
    }
}

1;
