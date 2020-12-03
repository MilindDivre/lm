#!/usr/bin/perl
use Switch;

#store all the content of the file
my @file_data;

#store new content of file
my @new_file;
my $temp;
my $found = 1;
my $modified = 0;

switch ($ARGV[0])
{
	case "rclocal"
	{
		modify_rc_local();
	}
	break;
	case "limitsconf"
	{
		modify_limits_conf();
	}
	break;
	case "commonsession"
	{
		modify_common_session();
	}
	break;
	case "ldsoconf"
	{
		modify_ld_so_conf();
	}
	break;
	case "vsftpd"
	{
		modify_vsftpd_conf();
	}
	break;
	case "updateavailable"
	{
		modify_update_mod_d();
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
		modify_apache_envvars($ARGV[1]);
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
		modify_dotbashrc($ARGV[1]);
	}
	break;
	case "addcomponent"
	{
		add_installation_component($ARGV[1]);
	}
	break;
	case "removecomponent"
	{
		remove_installation_component($ARGV[1]);
	}
	break;
	case "pghba_modify-after-installation"
	{
		modify_db_pghba_after_installation();
	}
	break;  
	case "settingphp"
	{
		modify_setting_dot_php($ARGV[1],$ARGV[2],$ARGV[3],$ARGV[4]);
	}
    	else
	{
		print "\nWrong command line argument you have provided to script\n";
	}
}

sub trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };
sub add_installation_component()
{
	my $line;
	my $last_index;
	my @component_list;
	my $found=0;
	my $temp1;
	
	$line = qx(cat /usr/share/multiplier/installation.txt);
	chomp($line);
	@component_list=split(/:/,$line);
	$last_index = $#component_list;
	
	my ($arg) = @_;
	if($arg eq '') { print "\n ERROR:You have not given any componet name to add in /usr/share/multiplier/installation.txt file\n";}
	else
	{
		if($last_index == -1)
		{
			system("echo $arg > /usr/share/multiplier/installation.txt");
		}
		else
		{
			foreach $temp(@component_list) {if($arg eq $temp){$found=1;break;}}

			if($found == 0)
			{
				$temp1 = $line . ":" . $arg;
				system("echo $temp1 > /usr/share/multiplier/installation.txt");
			}
			else
			{
				print "\n WARNING: Looks \"$arg\" multiplier's component is present in your machine\n";
			}
		}
	}
}

sub remove_installation_component()
{
	my $line;
	my $last_index;
	my @component_list;
	my @update_list;
	my $found=0;
	my $temp1;
	my $update_last_index;
	
	$line = qx(cat /usr/share/multiplier/installation.txt);
	chomp($line);
	@component_list=split(/:/,$line);
	$last_index = $#component_list;
	
	my ($arg) = @_;
	if($arg eq '') { print "\n ERROR:You have not given any componet name to add in /usr/share/multiplier/installation.txt file\n";}
	else
	{
		if($last_index == -1)
		{
			print "ERROR: looks no multiplier component had installed yet but you are trying to uninstall $arg \n";
		}
		else
		{
			foreach $temp(@component_list) 
			{
				if($arg eq $temp){ $found=1;} else { push(@update_list, $temp);}
			}
			$update_last_index = $#update_list;

			if($found == 1)
			{	
				if($update_last_index > -1)
				{
					$temp1 = join(':', @update_list[0 .. $update_last_index]);
					system("echo $temp1 > /usr/share/multiplier/installation.txt");
				}
				else{ system("> /usr/share/multiplier/installation.txt");}
			}
			else
			{
				print "\n ERROR: looks \"$arg\" multiplier's component is not installed in your machine\n";
			}
		}
	}
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
	print $pgsql_version;
	        
	open(MYCONF_FH, "</etc/postgresql/$pgsql_version/main/pg_hba.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/pg_hba.conf, $!";
	while( my $line = <MYCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	my $temp;
	my $found = 1;
	my $modified = 0;

	######################### Modifying the content of /etc/mysql/my.cnf file#########################
	#print "Now script will modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
                                    print "Got the modified block\n";
			}
			else
			{
				if("# hostnossl  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]\n" eq $temp)
				{
				    push(@new_file, "#*******Below block edited for Multiplier to access database from multiplier GUI in system ********\n\n");
				    push(@new_file, "hostssl      all       all   all           trust\nlocal        all       all   trust\n");
				    
				    push(@new_file, "\n#************Block finished***************\n");		    
				    push(@new_file, $temp);
				    $found = 0;
				    $modified = 1;
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
	}
	else
	{
		print "Some error occured to modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
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

}


sub modify_db_pghba_after_installation()
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
	print $pgsql_version;
	        
	open(MYCONF_FH, "</etc/postgresql/$pgsql_version/main/pg_hba.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/pg_hba.conf, $!";
	while( my $line = <MYCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	my $temp;
	my $found = 1;
	my $modified = 0;

	######################### Modifying the content of /etc/mysql/my.cnf file#########################
	#print "Now script will modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
                                    print "Got the modified block\n";
			}
			else
			{
				if("# hostnossl  DATABASE  USER  ADDRESS  METHOD  [OPTIONS]\n" eq $temp)
				{
				    push(@new_file, "#*******Below block edited for Multiplier to access database from multiplier GUI in system ********\n\n");
				    push(@new_file, "hostssl      all       all   all           password\nlocal        all       all   password\n");
				    
				    push(@new_file, "\n#************Block finished***************\n");		    
				    push(@new_file, $temp);
				    $found = 0;
				    $modified = 1;
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
	}
	else
	{
		print "Some error occured to modify the /etc/postgresql/$pgsql_version/main/pg_hba.conf file\n";
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
	        
	open(MYCONF_FH, "</etc/postgresql/$pgsql_version/main/postgresql.conf") or die "Couldn't open file /etc/postgresql/$pgsql_version/main/postgresql.conf, $!";
	while( my $line = <MYCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	my $temp;
	my $found = 1;
	my $modified = 0;

	######################### Modifying the content of /etc/mysql/my.cnf file#########################
	#print "Now script will modify the /etc/postgresql/$pgsql_version/main/postgresql.conf file\n";
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				if("# - Connection Settings -\n" eq $temp)
				{
				    push(@new_file, "#*******Below block edited for Multiplier to access database from multiplier GUI in system ********\n\n");
				    push(@new_file, "listen_addresses = '*'\n");
				    
				    push(@new_file, "\n#************Block finished***************\n");		    
				    push(@new_file, $temp);
				    $found = 0;
				    $modified = 1;
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modify the /etc/postgresql/$pgsql_version/main/postgresql.conf file\n";
	}
	else
	{
		print "Some error occured to modify the /etc/postgresql/$pgsql_version/main/postgresql.conf file\n";
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
}


sub modify_rc_local()
{
	$filename = "/etc/rc.local";
	if(-f "$filename")
	{
		print " $filename file is present. we need to append the multiplier related data now\n";
		
	}
	else
	{
		print " $filename not present\n";
		open(my $NEW_RCLOCAL_FH1, '>', "$filename") or die "Couldn't open file $filename, $!";
		print $NEW_RCLOCAL_FH1 "#!/bin/bash\n";
		close($NEW_RCLOCAL_FH1);
		system("chmod 755 $filename");
	}
	
	my $temp;
	my $found = 1;
	my $modified = 0;

	######################### Modifying the content of /etc/rc.local file#########################
	print "Modifying $filename file ...\n";
	open(RCLOCAL_FH, "<$filename") or die "Couldn't open file $filename, $!";
	while( my $temp = <RCLOCAL_FH>)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				if(eof)
				{
				    push(@new_file, $temp);
				    push(@new_file, "#*******Below block edited for Multiplier to icrease the resouce in system ********\n\n");
				    push(@new_file, "printf '80096' > /proc/sys/kernel/shmmni\n");
				    push(@new_file, "echo 500000 > /proc/sys/kernel/threads-max\n");
				    push(@new_file, "echo 445530 > /proc/sys/vm/max_map_count\n");
				    push(@new_file, "printf '500 164000 64 1024' > /proc/sys/kernel/sem\n");
				    push(@new_file, "printf '1' > /proc/sys/kernel/core_uses_pid\n");
				    push(@new_file, "#ulimit -s 4096\n\n");

				    push(@new_file, "#increase max open files\n");
				    push(@new_file, "ulimit -n 999999\n\n");

				    push(@new_file, "ulimit -c unlimited\n\n");

				    push(@new_file, "#Increase ephimeral port range\n");
				    push(@new_file, "sudo sysctl -w net.ipv4.ip_local_port_range=\"5000 65000\"\n");

				    push(@new_file, "#Reduce fin timeout so that more connections per second can be acheived\n");
				    push(@new_file, "sysctl -w net.ipv4.tcp_fin_timeout=60\n\n");

				    push(@new_file, "#By default system does not allow connection in wait state after use\n");
				    push(@new_file, "#Lets allow fast recycling of sockets in time_wait state and reuse them.\n");
                                    #"tcp_tw_recycle" is not usefull as ubuntu18.04 is using 4.15.0 version kernel
				    #push(@new_file, "sysctl -w net.ipv4.tcp_tw_recycle=1\n");
				    push(@new_file, "sysctl -w net.ipv4.tcp_tw_reuse=1\n\n");

				    push(@new_file, "#sysctl -w net.ipv4.netfilter.ip_conntrack_max=32768\n");
				    push(@new_file, "sysctl -w net.ipv4.tcp_orphan_retries=1\n");
				    push(@new_file, "sysctl -w net.ipv4.tcp_max_orphans=8192\n\n");

				    push(@new_file, "#Increase max fds\n");
				    push(@new_file, "#For FD added entries in /etc/security/limits.conf and /etc/pam.d/common-session\n\n");

				    push(@new_file, "#Server side - Max requests queued to a listen socket\n");
				    push(@new_file, "sudo sysctl -w net.core.somaxconn=65535\n\n");

				    push(@new_file, "#Increase lan card txque length\n");
                                    my @intf = qx/ip -o link show | awk -F': ' '{print $2}'/;
                                    foreach my $line (@intf)
                                    {
                                            my @interface = (split /: /, $line);
                                            push(@new_file, "ifconfig $interface['1'] txqueuelen 50000\n");
                                            undef @interface;
                                    }
				    push(@new_file, "\n#************Block finished***************\n");		    
				    

				    $found = 0;
				    $modified = 1;
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified $filename.\n";
	}
	else
	{
		print "Some error occured during $filename file modifying\n";
	}

	close(RCLOCAL_FH);
	system("rm -f $filename");
	
	open(my $NEW_RCLOCAL_FH, '>', "$filename") or die "Couldn't open file $filename, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_RCLOCAL_FH "$temp";
	}
	close($NEW_RCLOCAL_FH);
	system("chmod 755 $filename");

}

sub modify_limits_conf()
{
	print "Modifying /etc/security/limits.conf file ...\n";
	open(LIMITSCONF_FH, "</etc/security/limits.conf") or die "Couldn't open file /etc/security/limits.conf, $!";
	while( my $line = <LIMITSCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				if("#*               soft    core            0\n" eq $temp)
				{
				    push(@new_file, "#*******Below block edited for Multiplier to generate core file ********\n\n");

				    push(@new_file, "*                hard    nofile          999999\n");
	    			    push(@new_file, "*	         soft    nofile 	 999999\n");
				    push(@new_file, "root             hard    nofile          999999\n");
				    push(@new_file, "root             soft    nofile          999999\n");
				    push(@new_file, "*                soft    nproc           500000\n");
				    push(@new_file, "*                hard    nproc           500000\n");
				    push(@new_file, "root             soft    nproc           500000\n");
				    push(@new_file, "root             hard    nproc           500000\n");
				    push(@new_file, "*                soft    core            unlimited\n");
				    push(@new_file, "root             soft    core            unlimited\n");			    
				    push(@new_file, "\n#************Block finished***************\n");		    
				    push(@new_file, $temp);
				    $found = 0;
				    $modified = 1;
	
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified the /etc/security/limits.conf file\n";
	}
	else
	{
		print "Some error occured during /etc/security/limits.conf file modifying\n";
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
}

sub modify_common_session()
{
	print "Modifying /etc/pam.d/common-session file ...\n";

	open(COMMON_SESSION_FH, "</etc/pam.d/common-session") or die "Couldn't open file /etc/pam.d/common-session, $!";
	while( my $line = <COMMON_SESSION_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				if($temp =~ /session	required	pam_unix/)
				{
				    push(@new_file, "#*******Below block edited for Multiplier********\n\n");

				    push(@new_file, "session required pam_limits.so\n"); 
				    push(@new_file, "\n#************Block finished***************\n");		    
				    push(@new_file, $temp);
				    $found = 0;
				    $modified = 1;
	
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified /etc/pam.d/common-session file.\n";
	}
	else
	{
		print "Some error occured during /etc/pam.d/common-session file modifying\n";
	}

	close(COMMON_SESSION_FH);


	system("rm -f /etc/pam.d/common-session");
	
	open(my $NEW_COMMON_SESSION_FH, '>', '/etc/pam.d/common-session') or die "Couldn't open file /etc/pam.d/common-session, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_COMMON_SESSION_FH "$temp";
	}
	close($NEW_COMMON_SESSION_FH);
}

sub modify_ld_so_conf()
{
	print "Modifying /etc/ld.so.conf file ...\n";

	open(LDSOCONF_FH, "</etc/ld.so.conf") or die "Couldn't open file /etc/ld.so.conf, $!";
	while( my $line = <LDSOCONF_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				push(@new_file, "#*******Below block edited for Multiplier to load multiplier's library********\n\n");
				push(@new_file, "include /etc/ld.so.conf.d/loadmultiplier.conf\n"); 
				push(@new_file, "\n#************Block finished***************\n");		    
				push(@new_file, $temp);

				#Create the loadmultiplier.conf file in /etc/ld.so.conf.d directory
			
				system("rm -f /etc/ld.so.conf.d/loadmultiplier.conf");
				system("echo \"/usr/local/multiplier/system/libs\" >>/etc/ld.so.conf.d/loadmultiplier.conf");
				
				$found = 0;
				$modified = 1;
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified /etc/ld.so.conf file.\n";
	}
	else
	{
		print "Some error occured during /etc/ld.so.conf file modifying\n";
	}

	close(LDSOCONF_FH);


	system("rm -f /etc/ld.so.conf");
	
	open(my $NEW_LDSOCONF_FH, '>', '/etc/ld.so.conf') or die "Couldn't open file /etc/ld.so.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_LDSOCONF_FH "$temp";
	}
	close($NEW_LDSOCONF_FH);
}

sub modify_vsftpd_conf()
{
	print "Modifying /etc/vsftpd.conf file ...\n";

	open(VSFTPD_FH, "</etc/vsftpd.conf") or die "Couldn't open file /etc/vsftpd.conf, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
			
				if($temp =~ /local_enable/)
				{
					push(@new_file, "#*******Below block edited for Multiplier********\n\n");
					push(@new_file, "local_enable=YES\n");
					push(@new_file, "write_enable=YES\n");
				 	push(@new_file, "\n#************Block finished***************\n");
			
					$found = 0;
					$modified = 1;

				}
				else
				{
					push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified /etc/vsftpd.conf file.\n";
	}
	else
	{
		print "Some error occured during /etc/vsftpd.conf file modifying\n";
	}
	close(VSFTPD_FH);


	system("rm -f /etc/vsftpd.conf");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/vsftpd.conf') or die "Couldn't open file /etc/vsftpd.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);

	#To restart the service of FTP
	system("sudo service vsftpd restart");
}

sub modify_update_mod_d()
{
	print "For faster SSH, modifying in /etc/update-motd.d directory\n";
	if(-d "/etc/temp")
	{}
	else
	{
        	system("mkdir /etc/temp");
	}
        system("mv /etc/update-motd.d/* /etc/temp/.");

	#To load the loadmultiplier's library by multiplier executable
	system("ldconfig");
}

sub modify_apache_envvars()
{
	print "Modifying /etc/apache2/envvars file ...\n";
=cut
	Usage: system("./system_file_modify.pl \"apacheenvvars\" \"username\"");
=cut
	my $prev = 0;
	my $curr = 0;		
	my ($arg) = @_;
	if($arg eq '') { print "\n ERROR:You have not given any \"username\" name to modify the file /etc/apache2/envvars\n";}
	else
	{
		open(ENVVARS_FH, "</etc/apache2/envvars") or die "Couldn't open file /etc/apache2/envvars, $!";
		while( my $line = <ENVVARS_FH>)  
		{   
		    push(@file_data, $line);
		}

		$found = 1;
		$modified = 0;
		foreach $temp(@file_data)
		{
			if($found)
			{
				#Checking for edited or not
				if($temp =~ /Below block edited for Multiplier/)
				{
					    push(@new_file, $temp);			
					    $found = 0;
					    $modified = 1;
					    $prev = 1;
				}
				else
				{
			
					if($temp =~ /export APACHE_RUN_USER=www-data/)
					{
						push(@new_file, "#*******Below block edited for Multiplier********\n\n");
						push(@new_file, "export APACHE_RUN_USER=$arg\n");
						push(@new_file, "export APACHE_RUN_GROUP=$arg\n");
					 	push(@new_file, "\n#************Block finished***************\n");
			
						$found = 0;
						$modified = 1;
						$curr = 1;
					}
					else
					{
						push(@new_file, $temp);
					}
				}
			}
			else
			{
				if(($temp =~ /export APACHE_RUN_GROUP=www-data/) || ($temp =~ /export APACHE_RUN_USER=www-data/))
				{
					if($curr==1){}
					elsif($prev==1)
					{
						push(@new_file, $temp);
					}
				}
				else{push(@new_file, $temp);}
			}
		}

		if($modified)
		{
			print "Successfully modified /etc/apache2/envvars file.\n";
		}
		else
		{
			print "Some error occured during /etc/apache2/envvars file modifying\n";
		}
		close(ENVVARS_FH);

		system("rm -f /etc/apache2/envvars");
		
		open(my $NEW_ENVVARS_FH, '>', '/etc/apache2/envvars') or die "Couldn't open file /etc/apache2/envvars, $!";
		foreach $temp(@new_file)
		{
		    print $NEW_ENVVARS_FH "$temp";
		}
		close($NEW_ENVVARS_FH);
		system("chmod 644 /etc/apache2/envvars");
	}
	#system("/etc/init.d/apache2 restart");	
}

sub modify_apache_config()
{
	print "Modifying /etc/apache2/apache2.conf file ...\n";
=cut
	Usage: system("./system_file_modify.pl \"apacheconfig\"");
=cut
	my $var_www = 0;
	my $root = 0;
	my $prev = 0;
	my $curr = 0;		
	
	open(APACHE_CONFIFG_FH, "</etc/apache2/apache2.conf") or die "Couldn't open file /etc/apache2/apache2.conf, $!";
	while( my $line = <APACHE_CONFIFG_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				push(@new_file, $temp);			
				$found = 0;
				$modified = 1;
			}
			else
			{
				if($temp =~ /Directory \//)
				{
					if($root == 0)
					{
						push(@new_file, "#*******Below block edited for Multiplier********\n\n");
						push(@new_file, $temp);
						push(@new_file, "	Options FollowSymLinks\n");
						push(@new_file, "	AllowOverride All\n");
						push(@new_file, "	Require all denied\n");
						push(@new_file, "</Directory>\n");
					 	push(@new_file, "\n#************Block finished***************\n");
		
						$found = 0;
						$root = 1;
					}
					elsif($temp =~ /Directory \/var\/www\//)
					{
						if($var_www == 0)
						{
							push(@new_file, "#*******Below block edited for Multiplier********\n\n");
							push(@new_file, $temp);
							push(@new_file, "	Options Indexes FollowSymLinks\n");
							push(@new_file, "	AllowOverride All\n");
							push(@new_file, "	Require all granted\n");
							push(@new_file, "</Directory>\n");
						 	push(@new_file, "\n#************Block finished***************\n");
	
							$found = 0;
							$var_www = 1;
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
				else
				{
					push(@new_file, $temp);
				}				
			}
		}
		else
		{
			if($modified == 1){push(@new_file, $temp); next;}
			if($temp =~ /<\/Directory>/)
			{
				$found = 1;
			}
		}
	}

	if(($modified == 1) || (($var_www==1)&&($root==1)))
	{
		$modified=1;
	}	


	if($modified)
	{
		print "Successfully modified the /etc/apache2/apache2.conf file.\n";
	}
	else
	{
		print "Some error occured during /etc/apache2/apache2.conf file modifying\n";
	}

	close(APACHE_CONFIFG_FH);
	
	system("rm -f /etc/apache2/apache2.conf");
	open(my $NEW_APACHE_CONFIFG_FH, '>', '/etc/apache2/apache2.conf') or die "Couldn't open file /etc/apache2/apache2.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_APACHE_CONFIFG_FH "$temp";
	}
	close($NEW_APACHE_CONFIFG_FH);
	system("chmod 644 /etc/apache2/apache2.conf");
	system("sudo a2enmod rewrite");
}

sub modify_apache_default_config()
{
	print "Modifying the /etc/apache2/sites-available/000-default.conf file ...\n";
=cut
	Usage: system("./system_file_modify.pl \"apachedefaultconfig\"");
=cut
	open(VSFTPD_FH, "</etc/apache2/sites-available/000-default.conf") or die "Couldn't open file /etc/apache2/sites-available/000-default.conf, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
			
				if($temp =~ /DocumentRoot \/var\/www\/html/)
				{
					push(@new_file, "#*******Below block edited for Multiplier********\n\n");
					push(@new_file, "	DocumentRoot /var/www/html/lmtoolsdev.com/\n");
				 	push(@new_file, "\n#************Block finished***************\n");
			
					$found = 0;
					$modified = 1;

				}
				else
				{
					push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified /etc/apache2/sites-available/000-default.conf file.\n";
	}
	else
	{
		print "Some error occured during /etc/apache2/sites-available/000-default.conf file modifying\n";
	}
	close(VSFTPD_FH);

	system("rm -f /etc/apache2/sites-available/000-default.conf");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/apache2/sites-available/000-default.conf') or die "Couldn't open file /etc/apache2/sites-available/000-default.conf, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);

	#To restart the service of FTP
	#system("/etc/init.d/apache2 restart");
}

sub modify_php_ini()
{
	print "Modifying /etc/php/7.2/apache2/php.ini file ... \n";
=cut
	Usage: system("./system_file_modify.pl \"phpini\"");
=cut
	open(VSFTPD_FH, "</etc/php/7.2/apache2/php.ini") or die "Couldn't open file /etc/php/7.2/apache2/php.ini, $!";
	while( my $line = <VSFTPD_FH>)  
	{   
	    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
			
				if($temp =~ /extension=\/path\/to\/extension\/mysqli.so/)
				{
					push(@new_file, $temp);
					push(@new_file, "; *******Below block edited for Multiplier********\n;\n");
					push(@new_file, "extension=ssh2.so\n");
					push(@new_file, "extension=pdo.so\n");
					push(@new_file, "extension=pdo_mysql.so\n");
					push(@new_file, "extension=bz2\n");
					push(@new_file, "extension=mcrypt.so\n;");
				 	push(@new_file, "\n; ************Block finished***************\n");
			
					$found = 0;
					$modified = 1;

				}
				else
				{
					push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}

	if($modified)
	{
		print "Successfully modified the /etc/php/7.2/apache2/php.ini file.\n";
	}
	else
	{
		print "Some error occured during /etc/php/7.2/apache2/php.ini file modifying\n";
	}
	close(VSFTPD_FH);
	system("rm -f /etc/php/7.2/apache2/php.ini");
	
	open(my $NEW_VSFTPD_FH, '>', '/etc/php/7.2/apache2/php.ini') or die "Couldn't open file /etc/php/7.2/apache2/php.ini, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_VSFTPD_FH "$temp";
	}
	close($NEW_VSFTPD_FH);

	#To restart the service of FTP
	#system("/etc/init.d/apache2 restart");
}

sub modify_dotbashrc()
{
	my $temp;
	my $found = 1;
	my $modified = 0;

	print "Modifying $filename file ...\n";
	######################### Modifying the content of .bashrc file#########################
        my ($arg) = @_;
        if($arg eq '') { print "\n ERROR:You have not given user name to modify the .bashrc file for locale issue\n";}
        else{ 
        $uname = $arg;
        $filename = "/home/" . $uname . "/.bashrc";
   	open(RCLOCAL_FH, "<$filename") or die "Couldn't open file $filename, $!";
	while( my $temp = <RCLOCAL_FH>)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
			}
			else
			{
				if(eof)
				{
				    push(@new_file, $temp);
				    push(@new_file, "#*******Below block edited for Multiplier to fix locale issue in system ********\n\n");
				    push(@new_file, "export LANG=en_US.UTF-8\n");
				    push(@new_file, "export LANGUAGE=en_US.UTF-8\n");
				    push(@new_file, "export LC_ALL=en_US.UTF-8\n");
				    push(@new_file, "\n#************Block finished***************\n");		    
				    
				    $found = 0;
				    $modified = 1;
				}
				else
				{
				    push(@new_file, $temp);
				}
			}
		}
		else
		{
			push(@new_file, $temp);
		}
	}
        }

	if($modified)
	{
		print "Successfully modified $filename file.\n";
	}
	else
	{
		print "Some error occured during  $filename file modifying\n";
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
	system("update-locale");

}

sub modify_setting_dot_php()
{
	my $temp;
	my $found = 1;
	my $modified = 0;
    my $lastline = 1;
    my ($db_user, $db_name, $db_password, $uname) = @_;
  
    $filename = "/var/www/html/lmtoolsdev.com/sites/default/settings.php";
    #Usage: system("./system_file_modify.pl \"settingphp\" $db_user $db_name $user_password");

	open(SETTING_PHP_FH, "<$filename") or die "Couldn't open file $filename, $!";
	while( my $line = <SETTING_PHP_FH>)  
	{
    push(@file_data, $line);
	}

	$found = 1;
	$modified = 0;
    $edited = 0; 
	foreach $temp(@file_data)
	{
		if($found)
		{
			#Checking for edited or not
			if($temp =~ /Below block edited for Multiplier/)
			{
				    push(@new_file, $temp);			
				    $found = 0;
				    $modified = 1;
            $edited = 1;
			}
			else
			{
			
				if($temp =~ /databases = array/)
				{
					push(@new_file, "/*******Below block edited for Multiplier********/\n");
					push(@new_file, "    \$databases = array (\n");
          push(@new_file, "    'default' => array (\n");
          push(@new_file, "        'default' =>\n");
          push(@new_file, "          array (\n");
          push(@new_file, "            'database' => '$db_name',\n");
          push(@new_file, "            'username' => '$db_user',\n");
          push(@new_file, "            'password' => '$db_password',\n");
          push(@new_file, "            'host' => 'localhost',\n");
          push(@new_file, "            'port' =>'',\n");
          push(@new_file, "            'driver' => 'pgsql',\n");
          push(@new_file, "            'prefix' =>'',\n");
          push(@new_file, "          ),\n");
          push(@new_file, "        ),\n");
          push(@new_file, "    );\n");
				 	push(@new_file, "/************Block finished***************/\n");
			
					$found = 0;
					$modified = 1;

				}
				else
				{
					push(@new_file, $temp);
				}
			}
		}
		else
		{
        if($edited)
        {
            push(@new_file, $temp);
        }
        else
        {
            if($lastline)
            {
               if($temp =~ /\);/)
               {
                  $lastline = 0;
                  
               }
            }
    			  else
            {
               push(@new_file, $temp);
            }
        }
		}
	}

	if($modified)
	{
		print "Successfully modified the $filename file.\n";
	}
	else
	{
		print "Some error occured during $filename file modifying\n";
	}
	close(SETTING_PHP_FH);
	system("rm -f $filename");
	
	open(my $NEW_SETTING_PHP_FH, '>', "$filename") or die "Couldn't open file $filename, $!";
	foreach $temp(@new_file)
	{
	    print $NEW_SETTING_PHP_FH "$temp";
	}
	close($NEW_SETTING_PHP_FH);
    system("chmod 755 $filename");
    system("chown $uname:$uname $filename");
}
