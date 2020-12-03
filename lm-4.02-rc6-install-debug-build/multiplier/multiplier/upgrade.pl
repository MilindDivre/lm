#!/usr/bin/perl
use lib "../";
use util::Util qw(get_version_number);
use util::Util qw(print_white_space);
$version = get_version_number("../../");

multiplier_upgrade_start_msg();

if (-d "/usr/local/multiplier") 
{
    print "/usr/local/multiplier directory is exists\n";
}
else
{
    system("mkdir /usr/local/multiplier");
}

if (-d "/usr/local/multiplier/system")
{
    print "/usr/local/multiplier/system directory is exists\n";
    if(-d "/usr/local/multiplier/system/libs")
    {
        print "/usr/local/multiplier/system/libs exists\n";
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

multiplier_upgrade_complete_msg();

sub multiplier_upgrade_start_msg()
{
    my $text = "MULTIPLIER VERSION " . $version;
    print "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "+                                                                 +\n";
    print "+". print_white_space(23,$text,65) . "+\n";
    print "+                       MULTIPLIER UPGRADE                        +\n";
    print "+                                                                 +\n";
    print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
}

sub multiplier_upgrade_complete_msg()
{
    my $text = "MULTIPLIER VERSION " . $version;
    print "\n+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "+                                                                 +\n";
    print "+". print_white_space(23,$text,65) . "+\n";
    print "+                       MULTIPLIER UPGRADE COMPLETE               +\n";
    print "+                                                                 +\n";
    print "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n";
    print "\n\n\n\n\n\n";
}