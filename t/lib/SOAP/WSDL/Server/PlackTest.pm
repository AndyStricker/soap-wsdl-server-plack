package SOAP::WSDL::Server::PlackTest;
use parent qw(Test::Class);

use strict;
use warnings;

use Carp;
use Test::More;
use Test::Exception;
use HTTP::Request::Common qw(GET POST PUT DELETE);
use HTTP::Status qw(:constants);
use Plack::Test;
# You may add this to trace SOAP calls
#use SOAP::Lite +trace => [qw(all)];

use SOAP::WSDL::Server::Plack;

# As SOAP::WSDL client use LWP, we have to use a real HTTP server
# instead of the L<Plack::Test> MockHTTP default method.
$Plack::Test::Impl = 'Server';

sub construction_test : Test(5) {
	my ($self) = @_;

	my $soap;
	lives_ok(sub {
		$soap = SOAP::WSDL::Server::Plack->new({
			dispatch_to => 'DOES::NOT::EXIST',
			soap_service => 'DOES::NOT::EXIST::EITHER',
		});
	}, 'constructor with minimal required parameters works');
	isa_ok($soap, 'SOAP::WSDL::Server::Plack');
	can_ok($soap, 'psgi_app');

	dies_ok(sub {
		$soap = SOAP::WSDL::Server::Plack->new({
			soap_service => 'DOES::NOT::EXIST::EITHER',
		});
	}, 'missing "dispatch_to" raises exception');

	dies_ok(sub {
		$soap = SOAP::WSDL::Server::Plack->new({
			dispatch_to => 'DOES::NOT::EXIST',
		});
	}, 'missing "soap_service" raises exception');
}

sub app_test : Test(4) {
	my ($self) = @_;

	use_ok('Example::Server::HelloWorld::HelloWorldSoap');

	my $soap = SOAP::WSDL::Server::Plack->new({
		dispatch_to => 'Example::HelloWorldImpl',
		soap_service => 'Example::Server::HelloWorld::HelloWorldSoap',
	});

	my $app;
	lives_ok(sub {
		$app = $soap->psgi_app();
	});

	ok(defined $app, 'Got something from psgi_app()');
	is(ref($app), 'CODE', 'Got a code ref as app from psgi_app()');
}

sub server_test : Test(6) {
	my ($self) = @_;

	use_ok('Example::Server::HelloWorld::HelloWorldSoap');
	use_ok('Example::Interfaces::HelloWorld::HelloWorldSoap');

	my $app = SOAP::WSDL::Server::Plack->new({
		dispatch_to => 'Example::HelloWorldImpl',
		soap_service => 'Example::Server::HelloWorld::HelloWorldSoap',
	})->psgi_app();

	test_psgi $app, sub {
		my $cb = shift;
		my $request = GET '/';
		my $res = $cb->($request);
		is($res->code, HTTP_LENGTH_REQUIRED);

		# steal uri from request
		my $uri = $request->uri->clone();
		$uri->path('/');
		note 'Temporary web server url: ' . $uri;

		my $if = Example::Interfaces::HelloWorld::HelloWorldSoap->new({
			proxy => $uri->as_string(),
		});

		my $response;
		lives_ok(sub {
			$response = $if->sayHello({
				name => 'Wall',
				givenName => 'Larry',
			});
		}, 'Calling interface works');

		ok($response, 'Got successful result');
		unless ($response) {
			diag "$response";
		}
		is($response->get_sayHelloResult(), 'Hello Larry Wall');
	};
}

1;
