#!perl

`which -s resign`;
if ($?) {
	print "Check out and compile/install https://github.com/ehn-dcc-development/x509-resign.git first\n";
	exit(1);
};

my $ca = 'ca.pem';
my $cader = $ca;
$cader =~ s/\.pem/.crt/g;

my $careal = $ca;
$careal =~ s/\.pem/.real/g;

# Fetch the root and resign it
#
`curl --silent https://www.identrust.com/node/935 |\
	openssl pkcs7 -inform DER -print_certs |\
	openssl x509 -out $careal` unless -f $careal;

`cat $careal | resign -Ksi > $ca` unless -f $ca;

# Create version that can be imported into the emulator
#
`openssl x509 -in $ca -outform DER -out $cader`;

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

# Extract the issuers so we can get the order right
my %issuer, %subject;
for my $cert (@chain) {
	open(FH,">tmp.pem") or die $!;
	print FH $cert;
	close(FH);
	
	$i = `openssl x509 -in tmp.pem -noout -issuer`; $i =~ s/^\w+=//;
	$s = `openssl x509 -in tmp.pem -noout -subject`; $s =~ s/^\w+=//;
	$subject{$i} = $s;
	$issuer{$i} = $cert;
};

print "Reconstructing chain:\n";
my @chain = ();
$subject = `openssl x509 -in $ca -noout -subject`; $subject =~ s/^\w+=//;
print "Root: $subject";

while($issuer{$subject}) {
	print " sub: $subject";
	push @chain, $issuer{$subject};
	delete $issuer{$subject};
	$subject = $subject{$subject};
};
print "Leaf: $subject\n";
die "Unused stuff on the chain" if keys %issuer;

# Replace the private key in each item on the chain from the servery by 
# one we know; and sign it with the 'higher' up one.
#
my @filenames = ();
$idx = 1000;
for my $cert (@chain) {
	open(FH,">$idx.real") or die $!;
	print FH $cert;
	close(FH);

	`resign -K -s -i $idx.real $ca $ca > $idx.pem`;
	$ca = "$idx.pem";
	push @filenames, $ca;

	# unlink "$idx.real";
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
print "Check fake with \n\t$cmd\n\n";
system($cmd);
$cmd =~ s/.pem/.real/g;
print "Check real with \n\t$cmd\n\n";
system($cmd);

