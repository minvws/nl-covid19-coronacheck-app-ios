#!perl


my %pem2code = (
	'realRoot' => 'ca.real',
	'fakeRoot' => 'ca.pem',
	'realLeaf' => '1002.real',
	'fakeLeaf' => '1002.pem',
	'realChain01' => '1000.real',
	'fakeChain01' => '1000.pem',
	'realChain02' => '1001.real',
	'fakeChain02' => '1001.pem',
	'realCrossSigned' => 'cross.pem',
);

while (($var, $file) = each (%pem2code)) {
	$sha = `cat $file | openssl x509 -noout -sha256 -fingerprint`; chomp($sha); $sha =~ s/^[\w\s]+=\s*//;
	$subject = `cat $file | openssl x509 -noout -sha256 -subject`; chomp($subject); $subject =~ s/^\w+=\s*//;
	$issuer = `cat $file | openssl x509 -noout -sha256 -issuer`; chomp($issuer); $issuer =~ s/^\w+=\s*//;
	$info = join("\n// ",(split m/^\n/,$info));
	$content = `cat $file | openssl x509`;
	print <<"EOM";
// File:       : $file
// SHA256 (DER): $sha
// Subject     : $subject
// Issuer      : $issuer
//
let $var = """
$content""".data(using: .ascii)!

EOM
};

