#!/usr/bin/perl
use Getopt::Long;

my $start_index;
my $end_index;
my $temp;
my $help;
my $user_input;

if((util_check_default_values())==0)
{
	util_get_user_input();
        util_print_input_values();
        $user_input=print_msg_check_input("\nDo you want to continue ? [y/n]: ","y","n");
        if('N' =~ /$user_input/i)
        {
                print "You have entered \"$user_input\". So script is exiting now ...\n";
                exit;
        }
}

if($start_index >= $end_index)
{
	print "\nERROR: Wrong input ... \n";
        util_script_usage();
        exit;
}
else
{
	util_generate_device_file();
}
#print "\nstart index=$start_index end index=$end_index\n";
print "\n generate_devie_file.pl execution complete\n";

sub util_generate_device_file()
{

	for (my $i=$start_index; $i <= $end_index; $i++)
	{
		system("rm -rf /usr/local/multiplier/device/$i");
		system("mkdir /usr/local/multiplier/device/$i");
		system("cp -rp ./config/audio-in.amr /usr/local/multiplier/device/$i/.");
		system("cp -rp ./config/video-vp8-in.webm /usr/local/multiplier/device/$i/.");
		system("cp -rp ./config/audio-g711a-in.wav /usr/local/multiplier/device/$i/.");
		system("cp -rp ./config/audio-g711u-in.wav /usr/local/multiplier/device/$i/.");
		system("cp -rp ./config/audio-in.opus /usr/local/multiplier/device/$i/.");

		#It will copy key and certificate file to each device directory
		system("cp -rp /usr/local/multiplier/device/0/key.pem /usr/local/multiplier/device/$i/.");
		system("cp -rp /usr/local/multiplier/device/0/cert.pem /usr/local/multiplier/device/$i/.");
		system("cp -rp /usr/local/multiplier/device/0/ca-certificates.crt /usr/local/multiplier/device/$i/.");
		system("cp -rp /usr/local/multiplier/device/0/cert.der /usr/local/multiplier/device/$i/.");
		system("chmod -R 777 /usr/local/multiplier/device/$i");
		print "Device file generated for $i \n";
	}

}

sub get_user_input{

        my $ret;
        my ($msg, $option, $passwd) = (@_);

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

sub util_get_user_input()
{
	$start_index=get_user_input("Please enter the start device index number: ", "m", "o");
	$end_index=get_user_input("Please enter the end device index number: ", "m", "o");	
}

sub util_print_input_values()
{
	print "Start device index number : $start_index \n";
	print "End device index number : $end_index \n";
}

sub util_check_default_values()
{
        my $ret=1;
        GetOptions(
                   'start_index=s'    => \$start_index, 
                   'end_index=s'      => \$end_index,
                   'help|h'         => \$help,
                  );
        if($help){util_script_usage();exit;}
        unless($start_index){$ret=0;}
        unless($end_index){$ret=0;}
        return $ret;
}

sub util_script_usage()
{
        print "\nScript usage:";
        print "\n ./generate_device_file.pl --start_index start_devie_number --end_index end_device_number\n";
        print "\nExample:";
        print "\n ./generate_device_file.pl --start_index 101 --end_index 2000\n";

}
