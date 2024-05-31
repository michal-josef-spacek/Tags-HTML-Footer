package Tags::HTML::Footer;

use base qw(Tags::HTML);
use strict;
use warnings;

use Class::Utils qw(set_params split_params);
use Error::Pure qw(err);
use Mo::utils::Language 0.05 qw(check_language_639_2);
use Readonly;
use Scalar::Util qw(blessed);
use Unicode::UTF8 qw(decode_utf8);

Readonly::Array our @TEXT_KEYS => qw(version);

our $VERSION = 0.01;

# Constructor.
sub new {
	my ($class, @params) = @_;

	# Create object.
	my ($object_params_ar, $other_params_ar) = split_params(
		['lang', 'text'], @params);
	my $self = $class->SUPER::new(@{$other_params_ar});

	# Language.
	$self->{'lang'} = 'eng';

	# Language texts.
	$self->{'text'} = {
		'eng' => {
			'version' => 'Version',
		},
	};

	# Process params.
	set_params($self, @{$object_params_ar});

	# Check lang.
	check_language_639_2($self, 'lang');

	# Check text.
	if (! defined $self->{'text'}) {
		err "Parameter 'text' is required.";
	}
	if (ref $self->{'text'} ne 'HASH') {
		err "Parameter 'text' must be a hash with language texts.";
	}
	if (! exists $self->{'text'}->{$self->{'lang'}}) {
		err "Texts for language '$self->{'lang'}' doesn't exist.";
	}
	if (@TEXT_KEYS != keys %{$self->{'text'}->{$self->{'lang'}}}) {
		err "Number of texts isn't same as expected.";
	}
	foreach my $req_text_key (@TEXT_KEYS) {
		if (! exists $self->{'text'}->{$self->{'lang'}}->{$req_text_key}) {
			err "Text for lang '$self->{'lang'}' and key '$req_text_key' doesn't exist.";
		}
	}

	# Object.
	return $self;
}

sub _cleanup {
	my $self = shift;

	delete $self->{'_footer'};

	return;
}

sub _init {
	my ($self, $footer) = @_;

	# Check a.
	if (! defined $footer
		|| ! blessed($footer)
		|| ! $footer->isa('Data::HTML::Footer')) {

		err "Footer object must be a 'Data::HTML::Footer' instance.";
	}

	$self->{'_footer'} = $footer;

	return;
}

# Process 'Tags'.
sub _process {
	my $self = shift;

	if (! exists $self->{'_footer'}) {
		return;
	}

	$self->{'tags'}->put(
		['b', 'footer'],

		defined $self->{'_footer'}->version ? (
			['b', 'a'],
			defined $self->{'_footer'}->version_url ? (
				['a', 'href', $self->{'_footer'}->version_url],
			) : (),
			['d', $self->_text('version').': '.$self->{'_footer'}->version],
			['e', 'a'],
		) : (),

		defined $self->{'_footer'}->copyright_years ? (
			defined $self->{'_footer'}->version ? ['d', ',&nbsp;'] : (),
			['d', decode_utf8('©').' '.$self->{'_footer'}->copyright_years.' '],
		) : (),

		defined $self->{'_footer'}->author ? (
			['b', 'a'],
			defined $self->{'_footer'}->author_url ? (
				['a', 'href', $self->{'_footer'}->author_url],
			) : (),
			['d', $self->{'_footer'}->author],
			['e', 'a'],
		) : (),

		['e', 'footer'],
	);

	return;
}

sub _process_css {
	my $self = shift;

	if (! exists $self->{'_footer'}) {
		return;
	}

	$self->{'css'}->put(
		['s', '#main'],
		['d', 'padding-bottom', $self->{'_footer'}->height],
		['e'],

		['s', 'footer'],
		['d', 'text-align', 'center'],
		['d', 'padding', '10px 0'],
		['d', 'background-color', '#f3f3f3'],
		['d', 'color', '#333'],
		['d', 'position', 'fixed'],
		['d', 'bottom', 0],
		['d', 'width', '100%'],
		['d', 'height', $self->{'_footer'}->height],
		['e'],
	);

	return;
}

sub _text {
	my ($self, $key) = @_;

	return $self->{'text'}->{$self->{'lang'}}->{$key};
}

1;
