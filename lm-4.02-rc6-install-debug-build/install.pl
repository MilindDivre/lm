#!/usr/bin/perl
#!/bin/bash

multiplier_install_default_pkg();
system("./multiplier/util/mutiplier_install.pl");

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
    #system("cpan install switch");
    system("sudo apt-get -y install libterm-readkey-perl");
    system("sudo apt-get -y install build-essential");
    system("./multiplier/util/external/install_string_util.exp");
    system("cpan install String::Util");
}
