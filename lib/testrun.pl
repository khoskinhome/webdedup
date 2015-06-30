#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Webdedup::File;
use File::Find;

my $path = "../t-fixture-data/source-general/";

my @path = (
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/100NCD90/",
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/19450000-rene-bnw-1940s/",
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/20031100-canonA80"

);


find ( \&testfile, @path );

sub testfile {
    my $filename = $File::Find::name;


    my $exifhsh = Webdedup::File->getUniqueEXIF($filename);
    my $sha     = Webdedup::File->getFileDigest($filename);

    print "\n$filename\n    SHA=$sha\n    exif=".($exifhsh->{exif_string}||'')."\n";
    #print Dumper ( $exifhsh ) ;


}

