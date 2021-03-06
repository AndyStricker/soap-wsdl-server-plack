
package Example::Typemaps::HelloWorld;
use strict;
use warnings;

our $typemap_1 = {
               'sayHello/givenName' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
               'sayHelloResponse' => 'Example::Elements::sayHelloResponse',
               'Fault/faultactor' => 'SOAP::WSDL::XSD::Typelib::Builtin::token',
               'Fault/detail' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
               'sayHelloResponse/sayHelloResult' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
               'Fault/faultcode' => 'SOAP::WSDL::XSD::Typelib::Builtin::anyURI',
               'sayHello' => 'Example::Elements::sayHello',
               'sayHello/name' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
               'Fault/faultstring' => 'SOAP::WSDL::XSD::Typelib::Builtin::string',
               'Fault' => 'SOAP::WSDL::SOAP::Typelib::Fault11'
             };
;

sub get_class {
  my $name = join '/', @{ $_[1] };
  return $typemap_1->{ $name };
}

sub get_typemap {
    return $typemap_1;
}

1;

__END__

__END__

=pod

=head1 NAME

Example::Typemaps::HelloWorld - typemap for HelloWorld

=head1 DESCRIPTION

Typemap created by SOAP::WSDL for map-based SOAP message parsers.

=cut

