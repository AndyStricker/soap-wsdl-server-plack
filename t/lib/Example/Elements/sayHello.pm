
package Example::Elements::sayHello;
use strict;
use warnings;

{ # BLOCK to scope variables

sub get_xmlns { 'urn:HelloWorld' }

__PACKAGE__->__set_name('sayHello');
__PACKAGE__->__set_nillable();
__PACKAGE__->__set_minOccurs();
__PACKAGE__->__set_maxOccurs();
__PACKAGE__->__set_ref();

use base qw(
    SOAP::WSDL::XSD::Typelib::Element
    SOAP::WSDL::XSD::Typelib::ComplexType
);

our $XML_ATTRIBUTE_CLASS;
undef $XML_ATTRIBUTE_CLASS;

sub __get_attr_class {
    return $XML_ATTRIBUTE_CLASS;
}

use Class::Std::Fast::Storable constructor => 'none';
use base qw(SOAP::WSDL::XSD::Typelib::ComplexType);

Class::Std::initialize();

{ # BLOCK to scope variables

my %name_of :ATTR(:get<name>);
my %givenName_of :ATTR(:get<givenName>);

__PACKAGE__->_factory(
    [ qw(        name
        givenName

    ) ],
    {
        'name' => \%name_of,
        'givenName' => \%givenName_of,
    },
    {
        'name' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
        'givenName' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
    },
    {

        'name' => 'name',
        'givenName' => 'givenName',
    }
);

} # end BLOCK






} # end of BLOCK



1;


=pod

=head1 NAME

Example::Elements::sayHello

=head1 DESCRIPTION

Perl data type class for the XML Schema defined element
sayHello from the namespace urn:HelloWorld.







=head1 PROPERTIES

The following properties may be accessed using get_PROPERTY / set_PROPERTY
methods:

=over

=item * name

 $element->set_name($data);
 $element->get_name();




=item * givenName

 $element->set_givenName($data);
 $element->get_givenName();





=back


=head1 METHODS

=head2 new

 my $element = Example::Elements::sayHello->new($data);

Constructor. The following data structure may be passed to new():

 {
   name =>  $some_value, # string
   givenName =>  $some_value, # string
 },

=head1 AUTHOR

Generated by SOAP::WSDL

=cut

