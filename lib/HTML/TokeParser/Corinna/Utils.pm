package HTML::TokeParser::Corinna::Utils {
    use v5.37.8;
    use experimental 'signatures';
    use Module::Runtime 'use_module';
    use parent 'Exporter';
    our @EXPORT_OK = qw(throw);

    sub throw ( $name, %args ) {
        my $class = "HTML::TokeParser::Corinna::Exception::$name";
        die use_module($class)->new(%args);
    }
}

1;
