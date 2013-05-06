package SOAP::WSDL::Server::Plack::Transport;
use Moose;

use Carp;
use Try::Tiny;

# As SOAP::WSDL::Server is a Class::Std::Fast inside-out class we can't
# reliable inherit from it without using Class::Std::Fast too. Instead
# of inheritance we use a delegate pattern
use SOAP::WSDL::Server;

has 'action_map_ref' => (
	is => 'rw',
	isa => 'HashRef',
);

has 'class_resolver' => (
	is => 'rw',
	isa => 'Str',
);

has 'dispatch_to' => (
	is => 'rw',
	isa => 'Str',
);

# private server instance for delegate
has '_soap_wsdl_server' => (
	is => 'ro',
	isa => 'SOAP::WSDL::Server',
	lazy => 1,
	default => sub {
		my $self = $_[0];
		return SOAP::WSDL::Server->new({
			action_map_ref => $self->action_map_ref(),
			class_resolver => $self->class_resolver(),
			dispatch_to => $self->dispatch_to(),
		});
	},
	handles => [qw(
		get_action_map_ref
		set_action_map_ref
		get_class_resolver
		set_class_resolver
		get_dispatch_to
		set_dispatch_to
	)],
	documentation => 'Carry SOAP::WSDL::Server instance to delegate to',
);

=head2 handle

In case no transport class is defined this method is called by the
by the Plack server handler to dispatch to the SOAP server interface.

=cut

sub handle {
	my ($self, $req) = @_;

	my $logger = $req->logger();
	$logger = sub { } unless defined $logger;

	my $length = $req->headers->header('Content-Length');
	if (!$length) {
		$logger->({
			level => 'error',
			message => "No Content-Length provided",
		});
		# TODO maybe throw instead of returning a HTTP code?
		return 411; # Length required
	}

	# read may return less than requested - read until there's no more...
	my ($buffer, $read_length);
	my $body_psgi_input = $req->body();
	my $content = q{};
	while ($read_length = $body_psgi_input->read($buffer, $length)) {
		$content .= $buffer;
	}

	if ($length != length($content)) {
		$logger->({
			level => 'error',
			message => sprintf(
				"Read length mismatch; read [%d] bytes but received [%d] bytes",
				length($content), $length
			),
		});
		return 500;
	}

	# Shamelessly copied (with mild tweaks) from SOAP::WSDL::Server::Mod_Perl2
	# which was as shamelessly copied from SOAP::WSDL::Server::CGI which was
	# as shamelessly copied from SOAP::Transport::HTTP...
	my $request = HTTP::Request->new(
		$req->method() => $req->uri(),
		$req->headers->clone(),
		$content
	);
		#HTTP::Headers->new( SOAPAction => $req->headers->header('SOAPAction') ),

	my $response_message;
	try {
		#$response_message = $self->SUPER::handle($request);
		$response_message = $self->_soap_wsdl_server->handle($request);
	} catch {
		my $exception = $_;
		$logger->({
			level => 'error',
			message => "Failed to handle request: $exception",
		});
		return 500;
	};

	return $response_message;
};

__PACKAGE__->meta->make_immutable();

