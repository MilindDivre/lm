#!/usr/bin/perl
#use Switch;

use lib "./multiplier";
use Term::ReadKey;

use util::Util qw(print_msg_check_input);
use util::Util qw(restart_system);
use util::Util qw(is_component_installed);
use util::Util qw(print_astreek);

print "Multiplier uninstallation start...\n";


my $user_input;
my @temp;
my $webserver = 2;

$user_input=print_msg_check_input("\nPress 1 to uninstall all components of multiplier\nPress 2 to uninstall specific component of multiplier\n\nSelect the option you want to perform : ","1","2");
if('1' =~ /$user_input/i)
{
	#$webserver=print_msg_check_input("\nPress 1 to uninstall Desktop Application\nPress 2 to uninstall Web server\n\nPlease choose which frontend you want to uninstall : ", "1", "2");
	uninstall_all_component();
}
elsif('2' =~ /$user_input/i)
{
	uninstall_one_component();
	restart_system();
}
else
{
	print "You have entered \"$user_input\". It is a wrong input by you \n";
}
print "Final exit\n";

sub uninstall_all_component()
{
	my $input;
	$user_input=print_msg_check_input("\nYou are going to uninstall all component of multiplier form your machine \nDo you want to continue ? [y/n]: ","y","n");
	if('N' =~ /$user_input/i)
	{
		print "You have entered $user_input. So uninstallation process is exiting...\n";
		exit;
	}

	#system("sudo apt-get -y install libswitch-perl");

	#Installing the multiplier
        chdir './multiplier/multiplier';
        system("./uninstall.pl");
        chdir '../../';

        #Installing the controller
        chdir './multiplier/controller';
        system("./uninstall.pl");
        chdir '../../';
	
	if($webserver == 1)
	{
		print "\nMultiplier is going to uninstall Desktop application\n";
		#Uninstalling the frontend
		chdir './multiplier/frontend';
		system("./uninstall.pl");
		chdir '../../';

		#Uninstalling the database
		chdir './multiplier/database';
		system("./uninstall.pl");
		chdir '../../';
	}
	elsif($webserver == 2)
	{
		print "\nMultiplier is going to uninstall web server\n";
		chdir './multiplier/webserver';
		system("./uninstall.pl");
		chdir '../../';
	}
	else
	{
		print "\nWrong component selected for uninstallation\n";
	}
	
	if($webserver == 2)
	{
		if((is_component_installed("frontend")) == 1)
		{
			$user_input = print_msg_check_input("\nNow Desktop Application is installed in your machine\nDo you want to uninstall it ? [y/n]:","y","n");
			if('Y' =~ /$user_input/i)
			{
				print "\nMultiplier is going to uninstall Desktop application\n";
				#Uninstalling the frontend
				chdir './multiplier/frontend';
				system("./uninstall.pl");
				chdir '../../';
			}
		}

		if((is_component_installed("database")) == 1)
		{
			$user_input = print_msg_check_input("\nNow database is installed in your machine\nDo you want to uninstall it ? [y/n]:","y","n");
			if('Y' =~ /$user_input/i)
			{
				#Uninstalling the database
				chdir './multiplier/database';
				system("./uninstall.pl");
				chdir '../../';
			}
		}
	}
	elsif($webserver == 1)
	{
		if((is_component_installed("webserver")) == 1)
		{
			$user_input = print_msg_check_input("\nNow web server is installed in your machine\nDo you want to uninstall it ? [y/n]:","y","n");
			if('Y' =~ /$user_input/i)
			{
				print "\nMultiplier is going to uninstall web server\n";
				chdir './multiplier/webserver';
				system("./uninstall.pl");
				chdir '../../';
			}
		}
	}

	restart_system();
}


sub uninstall_one_component()
{
	my $input;
	print_menu();

	while(1)
	{
		$input=<STDIN>;
		chomp($input);

		if($input == 1)
		{
			#Installing the multiplier
			chdir './multiplier/multiplier';
			system("./uninstall.pl");
			chdir '../../';
		}
		elsif($input == 2)
		{
			#Installing the controller
			chdir './multiplier/controller';
			system("./uninstall.pl");
			chdir '../../';
		}
=cut
		elsif($input == 4)
		{
			#Installing the database
			chdir './multiplier/database';
			system("./uninstall.pl");
			chdir '../../';
		}
		elsif($input == 5)
		{
			#Installing the frontend
			chdir './multiplier/frontend';
			system("./uninstall.pl");
			chdir '../../';
		}
=cut
		elsif($input == 3)
		{
			#Installing the webserver
			chdir './multiplier/webserver';
			system("./uninstall.pl");
			chdir '../../';
		}
		elsif($input == 4)
		{
			return;
		}
		else
		{
			print "ERROR: Wrong choice you have entered \n";
		}
		print_menu();
	}
}

sub print_menu()
{
	system("clear");
        my $key;
        while( defined( $key = ReadKey(-1) ) ) {}
	print " Press 1 to uninstall multiplier\n";
	print " Press 2 to uninstall controller\n";
	print " Press 3 to uninstall web server\n";
=cut
	print " Press 4 to uninstall mysqldb\n";
	print " Press 5 to uninstall frontend(GUI)\n";
=cut
	print " Press 4 to finish uninstallation\n";
	print "\n Please choose the componet you want to uninstall :";
}



