#!/usr/bin/perl
use Getopt::Long;

use lib "../";

use util::Util qw(get_user_input);
use util::Util qw(print_msg_check_input);
use util::Util qw(get_version_number);
use util::Util qw(print_white_space);
use util::Util qw(get_username);

util::Util;

print "Multiplier installation start...\n";

$version = get_version_number("../../");

my @multiplier_pkg_list;
my $local_ip;
my $total_device=2000;
#my $total_device=20;
my $user_input;
my $temp;
my $machine_user;

multiplier_installation_start_msg();
if((multiplier_check_default_values())==0)
{
	multiplier_get_user_input();
	multiplier_print_input_values();
	$user_input=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
	if('N' =~ /$user_input/i)
	{
		print "You have entered $user_input. So multiplier installation process is exiting...\n";
		exit;
	}
}
multiplier_system_pkgs();

#We will store multiplier installation data in  /usr/share/multiplier path
if (-d "/usr/share/multiplier")
{
	if(-f "/usr/share/multiplier/installation.txt")
	{
	}
	else
	{
		system("touch /usr/share/multiplier/installation.txt");
	}
}
else
{
        system("mkdir /usr/share/multiplier");
	system("touch /usr/share/multiplier/installation.txt");
}
system("chmod -R 777 /usr/share/multiplier");

#Checking directory exists or not
if (-d "/usr/local/apat") 
{
}
else
{
	system("mkdir /usr/local/apat");
}
system("chmod 777 /usr/local/apat");

print "../util/generate_certificate.pl $local_ip\n";
#Generate the certificate for SSL connection
system("../util/generate_certificate.pl $local_ip");

multiplier_install_dependency_tcpdump();

if (-d "/usr/local/multiplier") 
{
}
else
{
	system("mkdir /usr/local/multiplier");
}

if (-d "/usr/local/multiplier/license") 
{
	if(-d "/usr/local/multiplier/license/multiplier")
	{
	}
	else
	{
		system("mkdir /usr/local/multiplier/license/multiplier");	
	}

}
else
{
	system("mkdir /usr/local/multiplier/license");
	system("mkdir /usr/local/multiplier/license/multiplier");
}

if (-d "/usr/local/multiplier/device")
{
        if(-d "/usr/local/multiplier/device/m")
        {
                system("rm -rf /usr/local/multiplier/device/m");
        }
}
else
{
        system("mkdir /usr/local/multiplier/device");
}

system("mkdir /usr/local/multiplier/device/m");

#checking the c directory,if available copy all the file to m direcotory otherwise copy all file from current directory and put it  in the m directory.
if(-d "/usr/local/multiplier/device/m")
{
	#copying the file from default directory to m directory
	system("cp -rp ./key.pem /usr/local/multiplier/device/m/.");
	system("cp -rp ./cert.pem /usr/local/multiplier/device/m/.");
	system("cp -rp ./ca-certificates.crt /usr/local/multiplier/device/m/.");
	system("cp -rp ./cert.der /usr/local/multiplier/device/m/.");
}
else
{
	print "\nERROR: Now \"m\" directory is not available in device path. So multiplier installation process exiting...\n";
}

if (-d "/usr/local/multiplier/device")
{
        if(-d "/usr/local/multiplier/device/b2ba")
        {
                system("rm -rf /usr/local/multiplier/device/b2ba");
        }
}
else
{
        system("mkdir /usr/local/multiplier/device");
}

system("mkdir /usr/local/multiplier/device/b2ba");

#checking the b2ba directory,if available copy all the file to b2ba direcotory otherwise copy all file from current directory and put it  in the b2ba directory.
if(-d "/usr/local/multiplier/device/b2ba")
{
	#copying the file from default directory to b2ba directory
	system("cp -rp ./key.pem /usr/local/multiplier/device/b2ba/.");
	system("cp -rp ./cert.pem /usr/local/multiplier/device/b2ba/.");
	system("cp -rp ./ca-certificates.crt /usr/local/multiplier/device/b2ba/.");
}
else
{
	print "\nERROR: Now \"b2ba\" directory is not available in device path. So multiplier installation process exiting...\n";
}

if (-d "/usr/local/multiplier/device")
{
        if(-d "/usr/local/multiplier/device/shell")
        {
                system("rm -rf /usr/local/multiplier/device/shell");
        }
}
else
{
        system("mkdir /usr/local/multiplier/device");
}

system("mkdir /usr/local/multiplier/device/shell");

if(-d "/usr/local/multiplier/device/shell")
{
	#copying the packetcapture.sh file util directory to b2ba directory
	system("cp -rp ../util/external/packetcapture.sh /usr/local/multiplier/device/shell/.");
	system("chmod 755 /usr/local/multiplier/device/shell/packetcapture.sh");
	system("chown $machine_user:$machine_user  /usr/local/multiplier/device/shell/packetcapture.sh");
}

if (-d "/usr/local/multiplier/system")
{
        if(-d "/usr/local/multiplier/system/libs")
        {
        }
        else
        {
                system("mkdir /usr/local/multiplier/system/libs");
        }

}
else
{
	system("mkdir /usr/local/multiplier/system");
	system("mkdir /usr/local/multiplier/system/libs");
}

system("cp -rp ../util/libs/* /usr/local/multiplier/system/libs/.");

if (-d "/usr/local/multiplier/system/bin")
{
        if(-d "/usr/local/multiplier/system/bin/multiplier")
        {
        }
        else
        {
                system("mkdir /usr/local/multiplier/system/bin/multiplier");
        }

}
else
{
	system("mkdir /usr/local/multiplier/system/bin");
	system("mkdir /usr/local/multiplier/system/bin/multiplier");
}
system("cp -rp ../repository/multiplier/* /usr/local/multiplier/system/bin/multiplier/.");

#Modify the system file to increase the resources and system files
push(@controller_pkg_list, "rclocal");
push(@controller_pkg_list, "limitsconf");
push(@controller_pkg_list, "commonsession");
push(@controller_pkg_list, "ldsoconf");
push(@controller_pkg_list, "vsftpd");
push(@controller_pkg_list, "updateavailable");
foreach $temp (@controller_pkg_list)
{
	system("../util/system_file_modify.pl $temp");
}

if($total_device <= 10)
{
	$total_device = 10;
	print "You have entered total device value less than 10,default value is 10\n";
}

print "\n Please Wait..... It will take few minutes to generate device directories\n";

for (my $i=0; $i <= $total_device; $i++)
{
	system("rm -rf /usr/local/multiplier/device/$i");
	system("mkdir /usr/local/multiplier/device/$i");

        if($i < 33)
        { 
        system("cp -rp ../util/config/audio-in.amr /usr/local/multiplier/device/$i/.");
	    system("cp -rp ../util/config/in-vp8.mlt /usr/local/multiplier/device/$i/.");
	    system("cp -rp ../util/config/in-h264.mlt /usr/local/multiplier/device/$i/.");
	    system("cp -rp ../util/config/audio-g711a-in.wav /usr/local/multiplier/device/$i/.");
	    system("cp -rp ../util/config/audio-g711u-in.wav /usr/local/multiplier/device/$i/.");
	    system("cp -rp ../util/config/audio-in.opus /usr/local/multiplier/device/$i/.");
        }
	
	#It will copy key and certificate file to each device directory
   	system("cp -rp ./key.pem /usr/local/multiplier/device/$i/.");
   	system("cp -rp ./cert.pem /usr/local/multiplier/device/$i/.");
   	system("cp -rp ./ca-certificates.crt /usr/local/multiplier/device/$i/.");
   	system("cp -rp ./cert.der /usr/local/multiplier/device/$i/.");
}

#Give full permission to device directory to write the output file
system("chmod -R 777 /usr/local/multiplier/device");

system("../util/system_file_modify.pl \"addcomponent\" \"multiplier\"");

system("ldconfig");
system("ldconfig");
system("sudo apt -y install python");
use Cwd qw(cwd);
my $dir = cwd;
my $dir_1= "$dir";
print "PWD:$dir_1\n";
system("../util/install_nodejs.py $dir");

#install nodejs and puppetor for headless
#system("../util/install_nodejs.py");

multiplier_clean_temp_files();

multiplier_installation_complete_msg();
 
#Multiplier script exeution will finish here

sub multiplier_check_default_values()
{
	my $ret=1;
	GetOptions('local_ip|l=s'    => \$local_ip, 'username=s'    => \$machine_user, 'help|h'  => \$help);
	if($help){multiplier_script_usage();exit;}
	unless($local_ip){$ret=0;}
    unless($machine_user){$ret=0;}
	return $ret;
}

sub multiplier_script_usage()
{
	print "\n Multiplier installation script usage:\n";
	print "\n ./install.pl --local_ip local-ip-address --username local_machine_username \n";
}

sub multiplier_clean_temp_files()
{
	if(-f "./key.pem") { unlink "./key.pem"; }else{ print "ERROR: key.pem file is not present \n";}
	if(-f "./cert.cfg") { unlink "./cert.cfg"; }else{ print "ERROR: cert.cfg file is not present\n";}
	if(-f "./cert.pem") { unlink "./cert.pem"; }else{ print "ERROR: cert.pem file is not present\n";}
	if(-f "./cert.der") { unlink "./cert.der"; }else{ print "ERROR: cert.der file is not present\n";}
	if(-f "./ca-certificates.crt") { unlink "./ca-certificates.crt"; }else{ print "ERROR: ca-certificates.crt file is not present\n";}
}

sub multiplier_print_input_values()
{
	print "\nMultiplier ip address = $local_ip \n";
    print "Local machine user name : $machine_user \n";
}

sub multiplier_get_user_input()
{
	$local_ip=get_user_input("Please enter the local machine ip address : ", "m", "o");
    $machine_user=get_username("Please enter the local machine user name: ");
}

sub multiplier_system_pkgs()
{
	#To update the ubuntu repository link
	#system("sudo apt-get update");
	
	#To install package to use switch case in perl script
	system("sudo apt-get -y install libswitch-perl"); 

	#SCTP
	system("sudo apt-get -y install lksctp-tools");

	#To play audio and video files
	system("sudo apt-get -y install ffmpeg");
	system("sudo apt-get -y install libjansson-dev");

	#system packages for certtool
	system("sudo apt-get -y install nettle-dev");
	system("sudo apt-get -y install nettle-bin");
	system("sudo apt-get -y install libtasn1-bin");
	system("sudo apt-get -y install libtasn1-dev");
	system("sudo apt-get -y install libtasn1-doc");
	system("sudo apt-get -y install libunistring-dev");

	#Install gnutls binary
	system("sudo apt-get -y install gnutls-bin");
	system("sudo apt-get -y install libcurl3-gnutls");

	#For FTP
	system("sudo apt-get -y install vsftpd");

	#For SSH
	system("sudo apt-get -y install ssh");
	
	system("sudo apt-get -y install libgsasl7-dev");

	#Install lua5.3
    system("sudo apt-get -y install lua5.3");
    system("sudo apt-get -y install liblua5.3-dev");
    system("sudo apt-get -y install curl libc6 libcurl4 zlib1g");
        #For recoreder.so
    system("sudo apt-get -y install libbrotli-dev");
    
}

sub multiplier_install_dependency_tcpdump()
{
    #To run tcpdump in normal user
    system("sudo groupadd pcap");
    system("sudo usermod -a -G pcap $machine_user");
    system("sudo chgrp pcap /usr/sbin/tcpdump");
    system("sudo setcap cap_net_raw,cap_net_admin=eip /usr/sbin/tcpdump");
    system("sudo ln -s /usr/sbin/tcpdump /usr/bin/tcpdump");
}

sub multiplier_license_start_msg()
{
	system("clear");
	print "\n++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
	print "+                                                                 			       +\n";
	print "+                       		MULTIPLIER VERSION $version                                 +\n";
	print "+    PLEASE PROVIDE THE CORRECT INFORMATION TO GENERATE THE TRIAL LICENSE FOR MULTIPLIER       +\n";
	print "+                                                                 			       +\n";
	print "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
}

sub multiplier_installation_start_msg()
{
    my $text = "MULTIPLIER VERSION " . $version;
    print "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "+                                                                 +\n";
    print "+". print_white_space(23,$text,65) . "+\n";
    print "+                       MULTIPLIER INSTALLATION                   +\n";
    print "+                                                                 +\n";
    print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
}

sub multiplier_installation_complete_msg()
{
    my $text = "MULTIPLIER VERSION " . $version;
    print "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "+                                                                 +\n";
    print "+". print_white_space(23,$text,65) . "+\n";
    print "+                  MULTIPLIER INSTALLATION COMPLETE               +\n";
    print "+                                                                 +\n";
    print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "\n\n\n\n\n\n";
}
