#!/usr/bin/perl
use Switch;

print "\n Revert back the system file changes\n";

#store all the content of the file
#my @file_data;

#store new content of file
#my @new_file;

#my $start_block = 1;
#my $end_block = 1;
#my $start_writing = 1;

switch ($ARGV[0])
{
	case "rclocal"
	{
		rclocal();
	}
	break;
	case "limitsconf"
	{
		limitsconf();
	}
        break;
	case "commonsession"
	{
		commonsession();
	}
        break;
	case "ldsoconf"
	{
		ldsoconf();
	}
        break;
	case "vsftpd"
	{
		vsftpd();
	}
        break;
	case "updateavailable"
	{
		updateavailable();
	}
        break;
	case "pghba"
	{
		modify_db_pghba();
	}
        break;
	case "postgresql"
	{
		modify_db_postgresql();
	}
        break;
	case "apacheenvvars"
	{
		modify_apache_envvars();
	}
        break;
	case "apacheconfig"
	{
		modify_apache_config();
	}
	break;
	case "apachedefaultconfig"
	{
		modify_apache_default_config();
	}
	break;
	case "phpini"
	{
		modify_php_ini();
	}
	break;
	case "bashrc"
	{
		modify_dotbashrc();
	}
	break;
	case "allmultipliercomp"
	{
		remove_multiplier_all_component();
	}
	
	else
	{
		print "\n Wrong command line argument you have provided to script\n";
	}
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub remove_multiplier_all_component()
{
	rclocal();
	limitsconf();
	commonsession();
	ldsoconf();
	vsftpd();
	updateavailable();
	modify_db_pghba();
	modify_db_postgresql();
	modify_apache_envvars();
	modify_apache_config();
	modify_apache_default_config();
	modify_php_ini();
    modify_dotbashrc();
    system("rm -rf /usr/local/apat");
    if(!(-d "/usr/local/multiplier/system/includes"))
    {
        system("rm -rf /usr/local/multiplier");
    }
    system("rm -rf /usr/share/multiplier");
    system("rm -rf /usr/share/applications/load-multiplier.desktop");
    system("rm -rf /usr/sbin/Multiplier");

	#Don't put remove_all_system_pkg() in top of this function
	remove_all_system_pkg();
}

sub remove_all_system_pkg()
{

	#To install package to use switch case in perl script
	#system("sudo apt-get -y remove libswitch-perl"); 

	#SCTP
	system("sudo apt-get -y remove lksctp-tools");

	#Install gnutls binary
	system("sudo apt-get -y remove gnutls-bin");

	#For FTP
	#system("sudo apt-get -y remove vsftpd");

	#For SSH
	#system("sudo apt-get -y remove ssh");

	#For qtsql
	system("sudo apt-get -y remove libqt5sql5-mysql");
	
	#system("sudo apt-get -y remove apache2 php5-mysql");

	#system("sudo apt-get -y remove php5 libapache2-mod-php5 php5-mcrypt php5-gd");

}

sub rclocal()
{
	$filename = "/etc/rc.local";
	#store all the content of the file
	my @file_data;

	#store new content of file
	my @new_file;

	my $start_block = 1;
	my $end_block = 1;
	my $start_writing = 1;

	open(RCLOCAL_FH, "<$filename") or die "Couldn't open file $filename, $!";
	while( my $line = <RCLOCAL_FH>)  
	{   
	    push(@file_data, $line);
	}
	close(RCLOCAL_FH);
	
	######################### Modifying the content of /etc/rc.local file#########################
	print "Modifying $filename file\n";
	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
        }

	system("rm -f $filename");
	open(my $NEW_RCLOCAL_FH, '>', "$filename") or die "Couldn't open file $filename, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_RCLOCAL_FH "$temp";
	}
	close($NEW_RCLOCAL_FH);
	system("chmod 755 $filename");
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub modify_db_pghba()
{
	my @list;
        my $output = qx(pg_config --bindir);
        my $pgsql_version;
        foreach my $line (split /[\/]+/, $output)
        {
		$line = trim($line);
		push(@list, $line);
	}
	$pgsql_version=$list[4];

        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	open(MYCONF_FH, "</etc/postgresql/$pgsql_version/main/pg_hba.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/pg_hba.conf, $!";
	while( my $line = <MYCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	
	######################### Modifying the content of /etc/mysql/my.cnf file#########################
	
	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
        }

	close(MYCONF_FH);

	system("rm -f /etc/postgresql/$pgsql_version/main/pg_hba.conf");
	open(my $NEW_MYCONF_FH, ">/etc/postgresql/$pgsql_version/main/pg_hba.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/pg_hba.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_MYCONF_FH "$temp";
	}
	close($NEW_MYCONF_FH);

	system("chmod 640 /etc/postgresql/$pgsql_version/main/pg_hba.conf");
	system("chown postgres:postgres /etc/postgresql/$pgsql_version/main/pg_hba.conf");
	undef @file_data;
	undef @new_file;
	undef $start_block;
	undef $end_block;
	undef $start_writing;
        undef @list;
   	undef $output;
	undef $pgsql_version;
}

sub modify_db_postgresql()
{
	my @list;
        my $output = qx(pg_config --bindir);
        my $pgsql_version;
        foreach my $line (split /[\/]+/, $output)
        {
		$line = trim($line);
		push(@list, $line);
	}
	$pgsql_version=$list[4];

        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	open(MYCONF_FH, "</etc/postgresql/$pgsql_version/main/postgresql.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/postgresql.conf, $!";
	while( my $line = <MYCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	
	######################### Modifying the content of /etc/mysql/my.cnf file#########################
	
	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
        }

	close(MYCONF_FH);

	system("rm -f /etc/postgresql/$pgsql_version/main/postgresql.conf");
	open(my $NEW_MYCONF_FH, ">/etc/postgresql/$pgsql_version/main/postgresql.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/postgresql.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_MYCONF_FH "$temp";
	}
	close($NEW_MYCONF_FH);

	system("chmod 644 /etc/postgresql/$pgsql_version/main/postgresql.conf");
	system("chown postgres:postgres /etc/postgresql/$pgsql_version/main/postgresql.conf");

	undef @file_data;
	undef @new_file;
	undef $start_block;
	undef $end_block;
	undef $start_writing;
        undef @list;
   	undef $output;
	undef $pgsql_version;
}

sub limitsconf()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	######################### Modifying the content of /etc/security/limits.conf#########################
	print "Modifying the /etc/security/limits.conf file ...\n";

	open(LIMITSCONF_FH, "</etc/security/limits.conf") or die "Couldn't open file /etc/security/limits.conf, $!";
	#open(LIMITSCONF_FH, "<./limits.conf") or die "Couldn't open file /etc/security/limits.conf, $!";
	while( my $line = <LIMITSCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	close(LIMITSCONF_FH);

	#remove the file /etc/security/limits.conf
	system("rm -f /etc/security/limits.conf");
	#system("rm -f ./limits.conf");

	open(my $NEW_LIMITSCONF_FH, '>', '/etc/security/limits.conf') or die "Couldn't open file /etc/security/limits.conf, $!";
	#open(my $NEW_LIMITSCONF_FH, '>', './limits.conf') or die "Couldn't open file /etc/security/limits.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_LIMITSCONF_FH "$temp";
	}
	close($NEW_LIMITSCONF_FH);
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub commonsession()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	######################### Modifying the content of /etc/pam.d/common-session#########################
	#print "Now script will modify the /etc/pam.d/common-session file\n";

	open(COMMON_SESSION_FH, "</etc/pam.d/common-session") or die "Couldn't open file /etc/pam.d/common-session, $!";
	#open(COMMON_SESSION_FH, "<./common-session") or die "Couldn't open file /etc/pam.d/common-session, $!";
	while( my $line = <COMMON_SESSION_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}		
	}

	close(COMMON_SESSION_FH);

	#remove the file /etc/pam.d/common-session
	system("rm -f /etc/pam.d/common-session");
	#system("rm -f ./common-session");

	open(my $NEW_COMMON_SESSION_FH, '>', '/etc/pam.d/common-session') or die "Couldn't open file /etc/pam.d/common-session, $!";
	#open(my $NEW_COMMON_SESSION_FH, '>', './common-session') or die "Couldn't open file /etc/pam.d/common-session, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_COMMON_SESSION_FH "$temp";
	}
	close($NEW_COMMON_SESSION_FH);
	undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub ldsoconf
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	######################### Modifying the content of /etc/ld.so.conf#########################
	print "Modifying the /etc/ld.so.conf file ...\n";

	open(LDSOCONF_FH, "</etc/ld.so.conf") or die "Couldn't open file /etc/ld.so.conf, $!";
	#open(LDSOCONF_FH, "<./ld.so.conf") or die "Couldn't open file /etc/ld.so.conf, $!";
	while( my $line = <LDSOCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	close(LDSOCONF_FH);
        #To remove loadmultiplier configuration file for loading dynamic library
        if (-f "/etc/ld.so.conf.d/loadmultiplier.conf")
        {
                system("rm -f /etc/ld.so.conf.d/loadmultiplier.conf");
        }	

	#remove the file /etc/ld.so.conf
	system("rm -f /etc/ld.so.conf");
	#system("rm -f ./ld.so.conf");

	open(my $NEW_LDSOCONF_FH, '>', '/etc/ld.so.conf') or die "Couldn't open file /etc/ld.so.conf, $!";
	#open(my $NEW_LDSOCONF_FH, '>', './ld.so.conf') or die "Couldn't open file /etc/ld.so.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_LDSOCONF_FH "$temp";
	}
	close($NEW_LDSOCONF_FH);
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub vsftpd()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	######################### Modifying the content of /etc/vsftpd.conf#########################
	print "Modifying /etc/vsftpd.conf file ...\n";

	open(VSFTPD_FH, "</etc/vsftpd.conf") or die "Couldn't open file /etc/vsftpd.conf, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					push(@new_file, "local_enable=YES\n");
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}		
	}
	close(VSFTPD_FH);
	#remove the file /etc/vsftpd.conf
	system("rm -f /etc/vsftpd.conf");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/vsftpd.conf') or die "Couldn't open file /etc/vsftpd.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);
	
	#To restart the service of FTP
	system("sudo service vsftpd restart");
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub updateavailable()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;

	#########################For faster SSH Login#########################
	#print "For faster SSH, modifying in /etc/update-motd.d directory\n";
	if (-d "/etc/update-motd.d")
	{
		print "/etc/update-motd.d directory is available\n";
	}
	else
	{
		system("makdir /etc/update-motd.d");
	}
	system("mv /etc/temp/* /etc/update-motd.d/.");
	system("rm -rf /etc/temp");
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub modify_apache_envvars()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;
=cut
	Usage: system("./getback_system_file.pl \"apacheenvvars\"");
=cut
	######################### Modifying the content of /etc/apache2/envvars#########################
	print "Modifying /etc/apache2/envvars file ...\n";

	open(VSFTPD_FH, "</etc/apache2/envvars") or die "Couldn't open file /etc/apache2/envvars, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					push(@new_file, "export APACHE_RUN_USER=www-data\n");
					push(@new_file, "export APACHE_RUN_GROUP=www-data\n");
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}		
	}
	
	close(VSFTPD_FH);
	system("rm -f /etc/apache2/envvars");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/apache2/envvars') or die "Couldn't open file /etc/apache2/envvars, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);
	system("chmod 644 /etc/apache2/envvars");
	system("/etc/init.d/apache2 restart");
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub modify_apache_config()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;
	my $root = 0;
	my $var_www = 0;
	my $modifying_block = 0;
        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;
=cut
	Usage: system("./getback_system_file.pl \"apacheconfig\"");
=cut
	######################### Modifying the content of /etc/apache2/envvars#########################
	print "Modifing /etc/apache2/apache2.conf file ...\n";

	open(VSFTPD_FH, "</etc/apache2/apache2.conf") or die "Couldn't open file /etc/apache2/apache2.conf, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($modifying_block)
		{
			if($temp =~ /Directory \//)
			{
				if($root == 0)
				{
					push(@new_file, $temp);
					push(@new_file, "	Options FollowSymLinks\n");
					push(@new_file, "	AllowOverride None\n");
					push(@new_file, "	Require all denied\n");
					push(@new_file, "</Directory>\n");
					$root = 1;
				}
				elsif($temp =~ /Directory \/var\/www\//)
				{
					push(@new_file, $temp);
					push(@new_file, "	Options Indexes FollowSymLinks\n");
					push(@new_file, "	AllowOverride None\n");
					push(@new_file, "	Require all granted\n");
					push(@new_file, "</Directory>\n");
				}
			}
			elsif($temp =~ /Block finished/)
			{
				$modifying_block = 0;
			}			 
	
		}
		elsif($temp =~ /Below block edited for Multiplier/)
		{
			$modifying_block = 1;
		}
		else
		{
			push(@new_file, $temp);
		}		
	}
	close(VSFTPD_FH);

	system("rm -f /etc/apache2/apache2.conf");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/apache2/apache2.conf') or die "Couldn't open file /etc/apache2/apache2.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);
	system("chmod 644 /etc/apache2/apache2.conf");
	system("/etc/init.d/apache2 restart");
        undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;

}

sub modify_apache_default_config()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;
=cut
	Usage: system("./getback_system_file.pl \"apachedefaultconfig\"");
=cut
	######################### Modifying the content of /etc/apache2/envvars#########################
	print "Modifying /etc/apache2/sites-available/000-default.conf file ...\n";

	open(VSFTPD_FH, "</etc/apache2/sites-available/000-default.conf") or die "Couldn't open file /etc/apache2/sites-available/000-default.conf, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					push(@new_file, "	DocumentRoot /var/www/html\n");
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}		
	}
	
	close(VSFTPD_FH);

	system("rm -f /etc/apache2/sites-available/000-default.conf");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/apache2/sites-available/000-default.conf') or die "Couldn't open file /etc/apache2/sites-available/000-default.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);
	system("chmod 644 /etc/apache2/sites-available/000-default.conf");
	undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub modify_php_ini()
{
        #store all the content of the file
        my @file_data;

        #store new content of file
        my @new_file;

        my $start_block = 1;
        my $end_block = 1;
        my $start_writing = 1;
=cut
	Usage: system("./getback_system_file.pl \"phpini\"");
=cut
	print "Modify /etc/php/7.2/apache2/php.ini file ...\n";

	open(VSFTPD_FH, "</etc/php/7.2/apache2/php.ini") or die "Couldn't open file /etc/php/7.2/apache2/php.ini, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					#push(@new_file, ";   extension=msql.so\n");
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}		
	}
	
	close(VSFTPD_FH);
	
	system("rm -f /etc/php/7.2/apache2/php.ini");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/php/7.2/apache2/php.ini') or die "Couldn't open file /etc/php/7.2/apache2/php.ini, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);
	system("chmod 644 /etc/php/7.2/apache2/php.ini");
	undef @file_data;
        undef @new_file;
        undef $start_block;
        undef $end_block;
        undef $start_writing;
}

sub modify_dotbashrc()
{
	$uname = `logname`;
	$uname =~ s/\r|\n|\r\n//g;
	$filename = "/home/" . $uname . "/.bashrc";

	#store all the content of the file
	my @file_data;

	#store new content of file
	my @new_file;

	my $start_block = 1;
	my $end_block = 1;
	my $start_writing = 1;

	open(RCLOCAL_FH, "<$filename") or die "Couldn't open file $filename, $!";
	while( my $line = <RCLOCAL_FH>)  
	{   
	    push(@file_data, $line);
	}

	######################### Modifying the content of .bashrc file#########################
	print "Modifying the $filename file ...\n";
	foreach $temp(@file_data)
	{
		if($start_writing)
		{		
			if($start_block)
			{
				if($temp =~ /Below block edited for Multiplier/)
				{
					$start_block = 0;
				}
				else
				{
					push(@new_file, $temp);
				}
			}
			else
			{
				if($temp =~ /Block finished/)
				{
					$end_block = 0;
					$start_writing = 0;
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
        }

	close(RCLOCAL_FH);

	system("rm -f $filename");

	open(my $NEW_RCLOCAL_FH, '>', "$filename") or die "Couldn't open file $filename, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_RCLOCAL_FH "$temp";
	}
	close($NEW_RCLOCAL_FH);
	system("chmod 644 $filename");
	system("chown $uname:$uname $filename");
}
