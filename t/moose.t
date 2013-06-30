use strict;
use warnings;
use Test::More;
use Test::Fatal;
use Test::Requires 'Moose';
use Test::Requires 'Test::Moose';

my $e0 = exception { {
	package Test0;
	use Moose;
	with 'Interface::Equatable';
} };

my $e1 = exception { {
	package Test1;
	use Moose;
	with 'Interface::Equatable';
	sub equals {}
} };

like $e0, qr/equals/, 'does not implement';
ok ! defined $e1,     'implements';

my $obj = new_ok 'Test1';

can_ok  $obj, 'equals';
does_ok $obj, 'Interface::Equatable';

ok $obj->meta->has_method('equals'), 'has method';
ok $obj->meta->does_role('Interface::Equatable'), 'does role';

done_testing;
