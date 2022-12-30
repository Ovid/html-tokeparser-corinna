#!/usr/bin/env perl

use lib 'lib';
use Test::Most;
use HTML::TokeParser::Corinna::Utils 'throw';

throws_ok { throw( VoidContext => method => 'some_method' ) }
'HTML::TokeParser::Corinna::Exception::VoidContext',
  'We should be able to throw a void context exception';
is $@->method, 'some_method', '... nad we can fetch the method name';
ok $@->stack_trace, '... and get a stack trace';
explain $@->to_string;

done_testing;
