#!/usr/bin/perl
use strict;

my $CP = "/bin/cp";
my $RM = "/bin/rm";
my $MKDIR = "/bin/mkdir";
my $HDIUTIL = "/usr/bin/hdiutil";
my $VERSION = "1.0";

my $RELEASEDIR = "/tmp/AD5RX\\ Morse\\ Trainer";

my @RELEASEFILES = (
                        "LICENSE",
                        "src",
                        "NoiseLicense.pdf",
                        "SparkleLicense.txt",
                        "Word\\ Files",
                        "QSO\\ Files",
                        "build/Release/MorseTrainer.app"
                   );

&main();

sub main()
{
    my $pwd = `pwd`;
    chomp($pwd);

    system("$RM -rf $RELEASEDIR");
    system("$MKDIR -p $RELEASEDIR");

    my $dmgimage = "$pwd/AD5RXMorseTrainer-$VERSION.dmg";
    
    foreach my $file (@RELEASEFILES)
    {
        system("$CP -R $file $RELEASEDIR");
    }

    system("$HDIUTIL create $dmgimage -srcfolder $RELEASEDIR");

    system("$RM -rf $RELEASEDIR");
}

