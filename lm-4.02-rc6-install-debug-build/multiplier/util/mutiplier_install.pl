#!/usr/bin/perl
#!/bin/bash

use lib "./multiplier";
use Term::ReadKey;

use util::Util qw(get_user_input);
use util::Util qw(print_msg_check_input);
use util::Util qw(restart_system);
use util::Util qw(is_component_installed);
use util::Util qw(print_astreek);
use util::Util qw(get_username);

print "Multiplier installation start...\n";

my ($local_ip, $db_ip, $db_root_passwd, $db_name, $db_user, $user_password, $db_srv_port, $machine_user, $machine_passwd, $ftp_port, $ssh_port,$uid);
my $user_input;
my $webserver = 2;

system('clear');
$user_input=print_msg_check_input("\nPress 1 to install multiplier \nPress 2 to upgrade multiplier\n\nSelect the option you want to perform : ", "1", "2");
if($user_input == 1 )
{
    multiplier_install();
}
elsif($user_input == 2)
{
    multiplier_upgrade();
}

sub multiplier_upgrade()
{  
    #multiplier_install_default_pkg();
    system('clear');
    $user_input=print_msg_check_input("\nPress 1 to upgrade all components of multiplier\nPress 2 to upgrade specific component of multiplier\n\nSelect the option you want to perform : ","1","2");
    if('1' =~ /$user_input/i)
    {
        multiplier_get_upgrade_user_input();
        if((multiplier_set_and_validate_default_values_for_upgrade())==0){exit;}
        multiplier_print_upgrade_user_input();
        $user_input=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
        if('N' =~ /$user_input/i)
        {
            print "You have entered $user_input. So multiplier's component is not going to upgrade in your machine.\n";
        }
        else
        {
            upgrade_all_component();
            system("sudo apt-get -f install");
            restart_system();
        }
    }
    elsif('2' =~ /$user_input/i)
    {
        upgrade_one_component();
        system("sudo apt-get -f install");
        restart_system();
    }
    else
    {
        print "You have entered wrong input \"$user_input\"\n";
    }

}

sub upgrade_all_component()
{

    #Upgrading the multiplier
    chdir './multiplier/multiplier';
    system("./upgrade.pl");
    chdir '../../';

    #Upgrading the controller
    chdir './multiplier/controller';
    system("./upgrade.pl");
    chdir '../../';

    #Upgrading the webserver
    chdir './multiplier/webserver';
    system("./upgrade.pl --db_ip $db_ip");
    chdir '../../';
}

sub upgrade_one_component()
{
    my $input;
    my $temp;
    print_upgrade_menu();
        
    while(1)
    {
        $input=<STDIN>;
        chomp($input);

        if($input == 1)
        {
            #Upgrading the multiplier
            $temp=print_msg_check_input("\nDo you want to continue upgrade multiplier ? [y/n]: ","y","n");
            if('N' =~ /$temp/i)
            {
                print "You have entered $temp. So multiplier is not going to upgrade in your machine.\n";
            }
            else
            {
                chdir './multiplier/multiplier';
                system("./upgrade.pl");
                chdir '../../';
            }
        }
        elsif($input == 2)
        {
            #Upgrading the controller
            $temp=print_msg_check_input("\nDo you want to continue upgrade controller ? [y/n]: ","y","n");
            if('N' =~ /$temp/i)
            {
                    print "You have entered $temp. So controller is not going to upgrade in your machine.\n";
            }
            else
            {
                chdir './multiplier/controller';
                system("./upgrade.pl");
                chdir '../../';
            }
        }
        elsif($input == 3)
        {
            #Upgrading the webserver
            $temp=print_msg_check_input("\nDo you want to continue upgrade webserver ? [y/n]: ","y","n");
            if('N' =~ /$temp/i)
            {
                print "You have entered $temp. So webserver is not going to upgrade in your machine.\n";
            }
            else
            {
                chdir './multiplier/webserver';
                system("./upgrade.pl");
                chdir '../../';
            }
        }
        elsif($input == 4)
        {
            return;
        }
        else
        {
            print "ERROR: Wrong choice you have entered \n";
        }
        print_upgrade_menu();
    }
}

sub multiplier_install()
{  
    #multiplier_install_default_pkg();
    system('clear');
    $user_input=print_msg_check_input("\nPress 1 to install all components of multiplier\nPress 2 to install specific component of multiplier\n\nSelect the option you want to perform : ","1","2");
    if('1' =~ /$user_input/i)
    {
        multiplier_get_all_user_input();
        if((multiplier_set_and_validate_default_values())==0){exit;}
        multiplier_print_user_input();
        
=cut
        $webserver=print_msg_check_input("\nPress 1 to install Desktop Application\nPress 2 to install Web server\n\nPlease choose which frontend you want to install : ", "1", "2");
            if($webserver == 1 )
            {
            if((multiplier_verify_userid())==0)
            {
                    print "\nERROR:Please provide the correct username and password at loadmultiplier.com\n";
                    exit;
            }
            }
=cut
            $user_input=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
        if('N' =~ /$user_input/i)
        {
            print "You have entered $user_input. So multiplier's component is not going to install in your machine.\n";
        }
        else
        {
            install_all_component();
            system("sudo apt-get -f install");
            restart_system();
        }
    }
    elsif('2' =~ /$user_input/i)
    {
        install_one_component();
        system("sudo apt-get -f install");
        restart_system();
    }
    else
    {
        print "You have entered wrong input \"$user_input\"\n";
    }
}

#Script execution complete here
sub install_all_component()
{
	#system("sudo apt-get -y update");
	
	#Installing the multiplier
	chdir './multiplier/multiplier';
	system("./install.pl --local_ip $local_ip --username $machine_user");
	chdir '../../';

	#Installing the controller
	chdir './multiplier/controller';
	system("./install.pl --local_ip $local_ip");
	chdir '../../';
	
	if($webserver == 1)
	{

		print "\nMultiplier is going to install Desktop application\n"; 
		#Installing the frontend
		chdir './multiplier/frontend';
		system("./install.pl --local_ip $db_ip --db_srv_port $db_srv_port --db_name $db_name --db_user $db_user --db_user_pwd $user_password");
		chdir '../../';

		#Installing the database
		chdir './multiplier/database';
		system("./install.pl --local_ip $db_ip -db_name $db_name --db_user $db_user --db_user_pwd $user_password --db_root_pwd $db_root_passwd --db_srv_port $db_srv_port --username $machine_user --password $machine_passwd --fpt_port $ftp_port --ssh_port $ssh_port --uid $uid");
		chdir '../../';
	}
	elsif($webserver == 2)
	{
		print "\nMultiplier is going to install web server\n";
		chdir './multiplier/webserver';
		system("./install.pl --db_name $db_name --db_user $db_user --db_user_pwd $user_password --username $machine_user");
		chdir '../../';
	}

}

sub install_one_component()
{
	my $input;
        my $temp;
	print_menu();
        
	while(1)
	{
		$input=<STDIN>;
		chomp($input);

		if($input == 1)
		{
			#Installing the multiplier
			multiplier_get_local_ip();
            multiplier_get_user_name();
			multiplier_print_local_ip();
            multiplier_print_user_name();
			$temp=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
			if('N' =~ /$temp/i)
			{
				print "You have entered $temp. So multiplier is not going to install in your machine.\n";
			}
			else
			{
				chdir './multiplier/multiplier';
				system("./install.pl --local_ip $local_ip --username $machine_user");
				chdir '../../';
			}
		}
		elsif($input == 2)
		{
			#Installing the controller
			multiplier_get_local_ip();
			multiplier_print_local_ip();
                        $temp=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
                        if('N' =~ /$temp/i)
                        {
                                print "You have entered $temp. So controller is not going to install in your machine.\n";
                        }
                        else
			{
				chdir './multiplier/controller';
				system("./install.pl --local_ip $local_ip");
				chdir '../../';
			}
		}
=cut
		elsif($input == 4)
		{
			#Installing the database
			if((multiplier_verify_userid())==0)
			{
        			print "\nERROR:Please provide the correct username and password at loadmultiplier.com\n";
        			exit;
			}
			multiplier_get_all_user_input();
			if((multiplier_set_and_validate_default_values())==0){exit;}
			multiplier_print_user_input();
			chdir './multiplier/database';
			system("./install.pl --local_ip $db_ip -db_name $db_name --db_user $db_user --db_user_pwd $user_password --db_root_pwd $db_root_passwd --db_srv_port $db_srv_port --username $machine_user --password $machine_passwd --fpt_port $ftp_port --ssh_port $ssh_port --uid $uid");
			chdir '../../';
		}
		elsif($input == 5)
		{
			#Installing the frontend
			multiplier_get_frontend_input();
			if((multiplier_check_frontend_values())==0){exit;}
			chdir './multiplier/frontend';
			multiplier_print_local_ip();
			multiplier_print_frontend_input();
                        if((is_component_installed("database")) == 0)
                        {
                                print "\nWARNING:Database component must be installed with frontend component\n";
                                print "Please press enter to continue...";
                                $input = <STDIN>;
                        }

			system("./install.pl --local_ip $db_ip --db_srv_port $db_srv_port --db_name $db_name --db_user $db_user --db_user_pwd $user_password");
			chdir '../../';
		}
=cut
		elsif($input == 3)
		{
			#Installing the webserver
			multiplier_get_webserver_input();
			multiplier_print_webserver_input();
			$temp=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
			if('N' =~ /$temp/i)
			{
				print "You have entered $temp. So webserver is not going to install in your machine.\n";
			}
			else
			{
				chdir './multiplier/webserver';
				system("./install.pl --db_name $db_name --db_user $db_user --db_user_pwd $user_password --username $machine_user");
				chdir '../../';
			}
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
	print "Press 1 to install multiplier\n";
	print "Press 2 to install controller\n";
	print "Press 3 to install Web server\n";
=cut
	print "Press 4 to install mysqldb\n";
	print "Press 5 to install frontend(GUI)\n";
=cut
	print "Press 4 to finish installation\n";
	print "\nPlease choose the componet you want to install :";
}

sub print_upgrade_menu()
{
	system("clear");
	print "Press 1 to upgrade multiplier\n";
	print "Press 2 to upgrade controller\n";
	print "Press 3 to upgrade Web server\n";
	print "Press 4 to finish upgrade\n";
	print "\nPlease choose the component you want to upgrade :";
}

sub multiplier_print_upgrade_user_input()
{
    print "Database machine ip address : $db_ip \n";
}
sub multiplier_get_upgrade_user_input()
{
    $db_ip=get_user_input("Please enter the database ip address: ", "m", "o");	
}
sub multiplier_set_and_validate_default_values_for_upgrade()
{
    if($db_ip eq "")
	{
		print "\nERROR:You have not entered any database ip address. So It is exiting from upgrade process \n";
		return 0;		
	}
    return 1;
}

sub multiplier_get_all_user_input()
{
	#$db_root_passwd=get_user_input("Please enter the mysql database root password: ", "m", "p");
        #$db_root_passwd="necs123";
	multiplier_get_frontend_input();
	$machine_user=get_username("Please enter the local machine user name: ");
=cut
	$machine_passwd=get_user_input("Please enter the password of user $machine_user: ", "m", "p");
	$ftp_port=get_user_input("Please enter the local machine sftp server running port(default 22): ","o","o");
	$ssh_port=get_user_input("Please enter the local machine ssh server running port(default 22): ", "o", "o");
=cut
	$local_ip=$db_ip;
}

sub multiplier_get_local_ip()
{
	$local_ip=get_user_input("Please enter the local machine ip address: ", "m", "o");	
	$db_ip=$local_ip;
}

sub multiplier_get_user_name()
{
    $machine_user=get_username("Please enter the local machine user name: ");
}
sub multiplier_print_user_name()
{
    print "Local machine user name : $machine_user \n";
}
sub multiplier_get_frontend_input()
{

	$db_name=get_user_input("Please enter the postgresql database name: ", "m", "o");
	$db_user=get_user_input("Please enter the postgresql database user name: ", "m", "o");
	$user_password=get_user_input("Please enter the password of postgresql database user $db_user: ", "m", "p");
	#$db_srv_port=get_user_input("Please enter the mysql server port(default 3306): ", "o", "o");
=cut
        $db_name="lmdb";
        $db_user="lmuser";
        $user_password="lm54321";
        #$db_srv_port=3306;
=cut

	$db_ip=get_user_input("Please enter the local machine ip address: ", "m", "o");
	$local_ip=$db_ip;
}

sub multiplier_print_user_input()
{
	multiplier_print_local_ip();
	#print "Postgre sql database root password : $db_root_passwd \n";
	#print "Postgre sql database root password : ";print_astreek(length($db_root_passwd));
	multiplier_print_frontend_input();
	print "Local machine user name : $machine_user \n";
	#print "Local machine password : $machine_passwd \n";
	#print "Local machine password : ";print_astreek(length($machine_passwd));	
	#print "\nLocal machine sftp server running port(default 22) : $ftp_port \n";
	#print "Local machine ssh server running port(default 22) : $ssh_port\n";	
}

sub multiplier_print_frontend_input()
{
	print "Postgresql database name : $db_name\n";
	print "Postgresql database user name : $db_user \n";
	print "Postgresql database user\($db_user\) password : ";print_astreek(length($user_password));
        print "\n";
	#print "Postgre sql database user's password : $user_password \n";
	#print "\nPostgre sql server port(default 5432) : $db_srv_port \n";
}

sub multiplier_print_local_ip()
{
	print "\nYour machine ip address is: $local_ip \n";
}

sub multiplier_get_webserver_input()
{
	#$db_root_passwd=get_user_input("Please enter the postgresql database root password: ", "m", "p");
	$db_name=get_user_input("Please enter the postgresql database name: ", "m", "o");
	$db_user=get_user_input("Please enter the postgresql database user name: ", "m", "o");
	$user_password=get_user_input("Please enter the password of postgresql database user $db_user: ", "m", "p");
=cut
        $db_name="lmdb";
        $db_user="lmuser";
        $user_password="lm54321";
        $db_root_passwd="necs123";
=cut
	$machine_user=get_username("Please enter the local machine user name: ");
}

sub multiplier_print_webserver_input()
{
	#print "Postgre sql database root password : $db_root_passwd \n";
	#print "Postgre sql database root password : ";print_astreek(length($db_root_passwd));
	print "\nPostgresql database name : $db_name\n";
	print "Postgresql database user name : $db_user \n";
	print "Postgresql database user\($db_user\) password : ";print_astreek(length($user_password));
	#print "Postgre sql database user\($db_user\) password : $user_password \n";
	print "\nLocal machine user name : $machine_user \n";
}

sub multiplier_check_frontend_values()
{
	my $ret=1;
	if($db_ip eq "")
	{
		print "\nERROR:You have not entered any database ip address. So It is exiting from installing process \n";
		$ret=0;		
	}
	if($user_password eq "")
	{
		print "\nERROR:You have not entered any database user's password. So It is exiting from installing process \n";
		$ret=0;
	}

	if($db_name eq "")
	{
		print "\nERROR:You have not entered any database name. So It is exiting from installing process \n";
		$ret=0;
	}
	
	if($db_user eq "")
	{
		print "\nERROR:You have not entered any database user name. So It is exiting from installing process \n";
		$ret=0;
	}
=cut
	if($db_srv_port eq "")
	{
		$db_srv_port=5432;
		print "WARNING:You have not entered postgre sql server port. So multiplier is setting the postgre sql server port to \"$db_srv_port\"\n";
	}
=cut
	return $ret;
}

sub multiplier_set_and_validate_default_values()
{

	if($local_ip eq "")
	{
		print "\nERROR:You have not entered any local ip. So It is exiting from installing process \n";
		return 0;		
	}

	if($machine_user eq "")
	{
		print "\nERROR:You have not entered local machine user name. So It is exiting from installing process\n";
		return 0;
	}
=cut
	if($machine_passwd eq "")
	{
		print "\nERROR:You have not entered local machine password. So It is exiting from installing process\n";
		return 0;
	}

	if($db_root_passwd eq "")
	{
		$db_root_passwd="multiplier123";
		print "\nWARNING:You have not entered postgre sql database root password. So multiplier is setting the password default value\n";
	}
=cut
	if($db_name eq "")
	{
		$db_name="lmdb";
		print "WARNING:You have not entered database name. So multiplier is setting the database name to \"$db_name\"\n";
	}
	
	if($db_user eq "")
	{
		$db_user="lmuser";
		print "WARNING:You have not entered database user name. So multiplier is setting the database user name to \"$db_user\"\n";
	}
=cut
	if($db_srv_port eq "")
	{
		$db_srv_port=3306;
		print "WARNING:You have not entered postgre sql server port. So multiplier is setting the mysql server port to \"$db_srv_port\"\n";
	}

	if($ftp_port eq "")
	{
		$ftp_port=22;
		print "WARNING:You have not entered sftp port. So multiplier is setting the mysql sftp port to \"$ftp_port\"\n";
	}
	if($ssh_port eq "")
	{
		$ssh_port=22;
		print "WARNING:You have not entered ssh port. So multiplier is setting the mysql ssh port to \"$ssh_port\"\n";
	}
=cut
	if($user_password eq "")
	{
		#$user_password="lm54321";	
		print "\nERROR:You have not entered database user's password. So exiting ... \n";
		return 0;
	}
	return 1;
}

sub multiplier_verify_userid()
{
	my $ret=0;
	my $data;
	my @recv_data;
	
	chdir './multiplier/database';
	system("./scripts/login.pl");
	if(-f "./loginid.txt")
	{
		$data = qx(cat ./loginid.txt);
		chomp($data);
		@recv_data = split(/:/,$data);
		$uid = $recv_data[1];
		if($uid > 0){ $ret=1;}else{"\nERROR:Login error\n";};
		unlink "./loginid.txt";
	}
	chdir '../..';
	return $ret;
}
=cut
sub multiplier_install_default_pkg()
{
    system("sudo apt-get update");
    system("sudo apt-get -y install net-tools");
    system("sudo apt-get -y install libhttp-daemon-ssl-perl");
    system("sudo apt-get -y install libwww-mechanize-perl");
    system("sudo apt-get -y install libswitch-perl");
    system("sudo apt-get -y install vim");
    system("sudo apt-get -y install expect");
    
    #Required for uninstall
    system("sudo apt-get -y install libdbi-perl");
    system("sudo apt-get -y install libdbd-pg-perl");
    system("./multiplier/webserver/scripts/install_switch.exp");
    system("cpan install switch");
    system("cpan install String::Util");
}
=cut
