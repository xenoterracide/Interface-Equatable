package Interface::Equatable;
use strict;
use warnings;

# VERSION

use Moo::Role;

requires('equals');

1;
# ABSTRACT: Interface::Equatable

=head1 SYNOPSIS

	use 5.014;

	package Parent {
		use Moo;
		with 'Interface::Equatable';

		use Scalar::Util qw( refaddr blessed );

		sub equals {
			my ( $self, $obj ) = @_;

			if ( refaddr $self == refaddr $obj ) {
				return 1;
			}
			elsif ( ! blessed $obj ) {
				return 0;
			}
			return; # results in an undef/false even in list context
			# we can't be 100% sure these aren't the same object at this point
			# we just didn't have a good metric here
		}
	}

	package Child {
		use Moo;
		extends 'Parent';

		has id => ( is => 'ro' );

		around equals {
			my $orig = shift;
			my $self = shift;

			my $bool = $self->$orig( @_ );

			return $bool if defined $bool;

			my $obj = shift;

			# ok this is probably overly simple we haven't checked type
			# anywhere
			return 1 if $obj->id eq $self->id;

			return;
		};
	}

	## in a class that needs and object to do this interface

	my $obj0 = Child->new( id => 1 );
	my $obj1 = Child->new( id => 1 );
	if ( $obj0->does('Interface::Equatable') && $obj0->equals( $obj1 ) ) {
		# do something with the equivalent objects
	}

=head1 DESCRIPTION

Defines a generalized method that a class implements to create a
method for determining equality of instances.


=method equals

	my $bool = $obj0->equals( $obj1 );

The equals method implements an equivalence relation on object references
and should return one of three boolean values: 1, 0, or undef. However,
this should never be checked by a consumer of the API. A consumer should only
check for true or false. The differences in values are only for implementers
of the interface.

	# NEVER DO THIS
	if( $obj0->equals( $obj ) == 1 ) { ...

	# ALWAYS DO THIS
	if ( $obj0->equals( $obj ) ) { ...

the contract for implmentors is as follows

=over

=item * It is reflexive

for C<$x>, C<$x->equals( $x )> should return
true.

=item * It is symmetric

For C<$x> and C<$y>, C<$x->equals( $y )> should return true if and only if
C<$y->equals( $x )> returns true.

=item * It is transitive

for any objects C<$x>, C<$y>, and C<$z>, if
C<$x->equals( $y )> returns true and C<$y->equals( $z )> returns true, then
C<$x->equals( $z )> should return true.

=item * It is consistent

Invocations of C<$x.equals( $y )> consistently return true or consistently return
false, provided no information used in equals comparisons on the objects is
modified.

=item * Undefined

For any implementing object C<$x>, C<$x->equals( undef )> should return false.

=over

=item C<1>

the value C<1> should be used when you know that the compared object is
equivalent and this is absolutely true. An example is if the reference address
is equal, you know they are the same object.

=item C<0>

The value C<0> should be used when you know that the compared object is
absolutely not equivalent. An example would be if the thing passed in is not
an object but instead a hashref.

=item C<undef>

The value C<undef> should be returned if your implementation of the subroutine
says well I didn't find these to be equal, but you can continue checking. This
is useful for the following kind of code.

	override equals => sub {
		my ( $self, $obj ) = @_;

		my $ret = super();

		return $ret unless ! defined $ret;

		# check more stuff
	};

The reason we might do this is in the parent class we may only have checked to
see if the reference or types are equivalent, but in the child class we also
want to do an identity check.

=back
