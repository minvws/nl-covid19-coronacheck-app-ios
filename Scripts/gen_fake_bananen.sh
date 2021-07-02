#!perl

if ! which -s resign; then
	echo Check out and compile/install https://github.com/ehn-dcc-development/x509-resign.git
  	echo first
	exit 1
fi

my $ca = 'ca.pem';
# Fetch the root and resign it
#
`curl --silent https://www.identrust.com/node/935 |\
	openssl pkcs7 -inform DER -print_certs |\
	openssl x509 |\
	resign -Ksi > $ca` unless -f $ca;

# Fetch full chain for the bananen API server
#
open(STDIN,'false | openssl s_client -connect api-ct.bananenhalen.nl:443 -showcerts |')
	or die $!;

my $cur = undef;
my @chain = ();
while(<STDIN>) {
	$cur = '' if m/-----BEGIN/;
	$cur .= $_ if defined($cur);
	if (m/-----END/) {
		push @chain, $cur;
		undef $cur;
	};
}

# Replace the private key in each item on the chain from the servery by 
# one we know; and sign it with the 'higher' up one.
#
my $idx = 1000;
my @filenames = ();
for my $cert (reverse(@chain)) {
	open(FH,">$idx.real") or die $!;
	print FH $cert;
	close(FH);
	`resign -K -s -i $idx.real $ca $ca > $idx.pem`;
	$ca = "$idx.pem";
	push @filenames, $ca;
	unlink "$idx.real";
	$idx++;
};

$last = pop @filenames;
$untrusted = join(' ',map { '-untrusted '.$_ } @filenames);

open(FH,">chain.pem") or die $!;
shift @chain;
for my $cert (reverse(@chain)) { print FH $cert; };
close(FH);

# Sanity check on our entire chain; with just the CA.
#
$cmd = "openssl verify -CAfile ca.pem -purpose any $untrusted $last";
system($cmd);

