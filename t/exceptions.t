#!/usr/bin/env perl

use lib 'lib';
use Test::Most;
use HTML::TokeParser::Corinna::Utils 'throw';
plan skip_all => 'overload does not yet work for Corinna';

throws_ok { throw( VoidContext => method => 'some_method' ) }
'HTML::TokeParser::Corinna::Exception::VoidContext',
  'We should be able to throw a void context exception';
is $@->method, 'some_method', '... nad we can fetch the method name';
ok $@->stack_trace, '... and get a stack trace';
explain $@->to_string;

throws_ok { throw( VoidContext => method => 'some_method', message => 'Additional information' ) }
'HTML::TokeParser::Corinna::Exception::VoidContext',
  'We should be able to throw a void context exception';
is $@->method, 'some_method', '... nad we can fetch the method name';
ok $@->stack_trace, '... and get a stack trace';
like $@->to_string, qr/Additional information/,
  '... and the stringified exception can carry an optional message';
explain $@->to_string;

done_testing;
