package util::Util;
use strict;
use warnings;

use Term::ReadKey;
use Exporter qw(import);

our @EXPORT_OK = qw(lm_trim get_user_input print_msg_check_input get_username print_astreek get_total_component get_first_component_name is_component_installed restart_system is_db_user_available is_db_available get_version_number print_white_space);

our $VERSION="3.02";

sub lm_trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

sub get_user_input{

        my $ret;
        my ($msg, $option, $passwd) = (@_);
        my $key;
        while( defined( $key = ReadKey(-1) ) ) {}
        
        START:
        print "\n$msg";
        if($passwd eq "p"){system('stty','-echo');}
        $ret=<STDIN>;
        chomp($ret);
        if($passwd eq "p"){system('stty','echo');print "\n";}
        if($option eq "m"){if($ret eq ""){goto START;}}

        return $ret;
}

sub print_msg_check_input{

        my $ret;
        my ($msg, $val1, $val2) = (@_);
        my $input1=0;
        my $input2=0;
        my $key;
        while( defined( $key = ReadKey(-1) ) ) {}

        START:
        print "$msg";
        $ret=<STDIN>;
        chomp($ret);
        if($val1 =~ /$ret/i){$input1=1;}
        if($val2 =~ /$ret/i){$input2=1;}
        if($ret eq ""){$input1=0;$input2=0}
        if(($input1==1) || ($input2==1)){return $ret;}
        else{print "\nWARNING:Please enter correct input...\n";goto START;}
}

sub get_username{
	my $user;
	my $output;
	my ($msg) = (@_);
	
        START:
        print "$msg";
        $user=<STDIN>;
        chomp($user);
	$output=`getent passwd $user`;
	if($output eq ""){print "\nWARNING:User \"$user\" is not available in your machine\n";goto START;}
	else{return $user;}
}

sub print_astreek{

        my ($length)=@_;
        for(my $i=0;$i<$length;$i++){print "*";}
}

sub get_total_component{

        my $line;
        my $last_index;
        my @component_list;
        my $total_component;

        $line = qx(cat /usr/share/multiplier/installation.txt);
        chomp($line);
        @component_list=split(/:/,$line);
        $last_index = $#component_list;
        $last_index = $last_index + 1;

        return $last_index;
}

sub get_first_component_name{

        my $line;
        my $last_index;
        my @component_list;
        my $total_component;

        $line = qx(cat /usr/share/multiplier/installation.txt);
        chomp($line);
        @component_list=split(/:/,$line);

        return $component_list[0];
}

sub is_component_installed{

        my $line;
        my $last_index;
        my @component_list;
        my $found=0;
        my $temp;

        $line = qx(cat /usr/share/multiplier/installation.txt);
        chomp($line);
        @component_list=split(/:/,$line);
        $last_index = $#component_list;

        my ($arg) = @_;
        if($arg eq '') { print "\n ERROR:You have not given any componet name\n";}
        else
        {
                if($last_index == -1)
                {
                        print "ERROR: Looks no multiplier component(i.e. $arg) had installed yet. \n";
                        return 0;
                }
                else
                {
                        foreach $temp(@component_list)
                        {
                                if($arg eq $temp){ $found=1;}
                        }
                }
        }
        if($found == 1)
        {
                return 1;
        }
        return 0;
}

sub restart_system{

        my $input;
        my $key;
        while( defined( $key = ReadKey(-1) ) ) {}

        print "Please press ENTER to restart your machine...";
        $input = <STDIN>;
        system("init 6");
}
sub is_db_user_available{

	my $temp=0;
	my $output;	
	
	my ($arg) = @_;
        if($arg eq '') { print "\n ERROR:You have not given any postgre sql db user name\n";}
	else
	{
		#Checking the database user is existing or not 
		$output = qx(sudo -u postgres psql -c \"SELECT usename FROM pg_user where usename=\'$arg\';"); 
		foreach my $line (split /[\r\n]+/, $output) 
		{
		        $line = lm_trim($line);
		        if($line eq "$arg")
		        {
		                print"\nDatabase user \"$arg\" is available in your machine \n";
		                $temp =1;
		                last;
		        }
		}		
	}

	return $temp;
}
sub is_db_available{

	my $temp=0;
	my $output;
	
	my ($arg) = @_;
        if($arg eq '') { print "\n ERROR:You have not given any postgre sql db name\n";}
	else
	{
		#checking database is present or not. if not available creating database
		$output = qx(sudo -u postgres psql -c "SELECT datname FROM pg_database where datname=\'$arg\'";);
		foreach my $line (split /[\r\n]+/, $output) 
		{
		        $line = lm_trim($line);
		        if($line eq "$arg")
		        {
				print"\nDatabase \"$arg\" is available in your machine \n";
		                $temp =1;
		                last;
			}
		}
	}
	return $temp;
}

sub get_version_number{

	my ($arg) = @_;
	if($arg eq '') { print "\n ERROR:You have not given \"README\" file path\n";}
	my $file_name="README-";
	opendir (DIR, $arg) or die "Failed to open directory $arg\n";
	my @dirs_found = grep { /^$file_name/ } readdir DIR;

	my @word = (split /[-]+/, $dirs_found[0], 2);
	my $version = $word[1];
	
	return $version;
}

sub print_white_space{
    
    my $out = "";
    my ($start_space, $text,$total_len) = @_;
    for(my $i=0;$i<$start_space;$i++){$out .= " ";} 
    $out .= $text;
    my $temp = length $text;
    my $len = $total_len - ($start_space + $temp);
    for(my $i=0;$i<$len;$i++){$out .= " ";}
    return $out;
}
1;
