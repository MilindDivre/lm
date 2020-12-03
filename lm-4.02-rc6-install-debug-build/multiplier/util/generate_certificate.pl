#!/usr/bin/perl

my $abs_path;
$num_args = $#ARGV + 1;
if ($num_args != 1) {
    print "\nUsage: ./generate_certificate.pl IP_Address\n";
    print "Example: ./generate_certificate.pl 192.168.1.4\n";
    exit;
}

$abs_path=qx(pwd);
chomp($abs_path);
print "\n Generating certificate\n";

#################Editing cert.cfg file#######################
system("rm -f ./cert.cfg");
system("rm -f ./key.pem");
system("rm -f ./cert.pem");
system("rm -f ./ca-certificates.crt");
system("rm -f ./cert.der");

#store all the content of the file
my @file_data;

#store new content of file
my @new_file;

open(CERTIFICATE_FH, "<../util/config/cert_template") or die "Couldn't open file ../util/config/cert_template, $!";
while( my $line = <CERTIFICATE_FH>)  
{   
    push(@file_data, $line);
}

my $temp;
my $ip_address;
my $found = 1;

foreach $temp(@file_data)
{
	if($found)
	{
		if($temp =~ /ip_address/)
		{
			$ip_address = 'ip_address = ' . '"' . $ARGV[0] . '"';
			push(@new_file, $ip_address);
			push(@new_file, "\n");			
			$found = 0;
		}
		else
		{
			push(@new_file, $temp);
		}
	}
	else
	{
		push(@new_file, $temp);
	}
}

if($found == 0)
{
	print "Successfully modify the ./cert.cfg file\n";
}
else
{
	print "Some error occured to modify the ./cert.cfg file\n";
}
close(CERTIFICATE_FH);

open(my $NEW_CERTIFICATE_FH, '>', './cert.cfg') or die "Couldn't open file ./cert.cfg, $!";
foreach $temp(@new_file)
{
    print $NEW_CERTIFICATE_FH "$temp";
}
close($NEW_CERTIFICATE_FH);

system("certtool --generate-privkey --outfile key.pem");
system("certtool --generate-self-signed --load-privkey key.pem --template cert.cfg --outfile cert.pem");
system("certtool --certificate-info --infile cert.pem");
system("certtool --outder -i --infile cert.pem --outfile  cert.der");
system("cp -rp ./cert.pem ./ca-certificates.crt");
system("chmod 777 ./key.pem ./cert.pem ./ca-certificates.crt ./cert.der");





