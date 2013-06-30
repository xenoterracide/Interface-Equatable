use strict;
use warnings;
use Test::More;
use Test::Fatal;

my $e0 = exception { {
	package Test0;
	use Moo;
	with 'Interface::Equatable';
} };

my $e1 = exception { {
	package Test1;
	use Moo;
	with 'Interface::Equatable';
	sub equals {}
} };

like $e0, qr/equals/, 'does not implement';
ok ! defined $e1,     'implements';

my $obj = new_ok 'Test1';

can_ok $obj, 'equals';
ok $obj->does('Interface::Equatable'), "Test1->does('Interface::Equatable')";

done_testing;
