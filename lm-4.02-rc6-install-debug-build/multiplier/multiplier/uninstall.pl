#!/usr/bin/perl

my $total_comp;
my $comp_name;
my $temp;
my $global_component_name="multiplier";

use lib "../";

use util::Util qw(print_msg_check_input);
use util::Util qw(is_component_installed);
use util::Util qw(get_first_component_name);
use util::Util qw(get_total_component);


#system("sudo apt-get -y install libswitch-perl");
$total_comp = get_total_component();
if($total_comp == 1)
{
	$comp_name = get_first_component_name();
	if($comp_name eq $global_component_name)
	{
		system("../util/getback_system_file.pl \"allmultipliercomp\"");
	}
	else
	{
		$temp = print_multiplier_uninstall_msg();
		if($temp == 1){remove_multiplier_only();}
	}
}
elsif($total_comp > 1)
{
	$temp = is_component_installed($global_component_name);
	if($temp == 1)
	{
		remove_multiplier_only();
	}
	else
	{
		$temp = print_multiplier_uninstall_msg();
		if($temp == 1){remove_multiplier_only();}
	}
}
else
{
	$temp = print_multiplier_uninstall_msg();
	if($temp == 1){remove_multiplier_only();}
}

system("../util/system_file_modify.pl \"removecomponent\" $global_component_name");

system("ldconfig");
system("ldconfig");

print "\nMultiplier uninstall script execution finish\n";


sub print_multiplier_uninstall_msg()
{
	$temp=print_msg_check_input("\nWARNING: Looks Multiplier is not available in your machine, Do you want to continue frocefully ? [y/n]: ","y","n");
	if('N' =~ /$temp/i)
	{
		print "You have entered \"$temp\". Multiplier uninstallation process is exiting...\n";
		return 0;
	}
	return 1;
}

sub remove_multiplier_only()
{
	my $controller;
	if(-d "/usr/local/multiplier/license/multiplier"){system("rm -rf /usr/local/multiplier/license/multiplier");}
	$controller = is_component_installed("controller");
	if($controller == 1)
	{
		system("cp -rp /usr/local/multiplier/device/c /usr/local/multiplier/.");	
	} 
	
	if(-d "/usr/local/multiplier/device"){system("rm -rf /usr/local/multiplier/device");}

	if($controller == 1)
	{
		system("mkdir /usr/local/multiplier/device");
		system("chmod -R 777 /usr/local/multiplier/device");
		system("mv -f /usr/local/multiplier/c /usr/local/multiplier/device/.");
		system("chmod -R 777 /usr/local/multiplier/device");
	}
}

