#!/usr/bin/perl
use strict;
use warnings;

#
## do all files in a certain path have duplicates in a different path ?
#
#
#how would we do that ?
#
#
#1) get all the records into the database.
#
#select files from the database that have a defined path
#can I find a duplicate that doesn't have the same root path ?
#

#/media/khoskin/2tb/

#select

# under a specific path , are all the files there also in a path with a different root ?
# i.e.
# /my/files/this-dir/probablyduplicate/
#
#
# are they all the files under there also found somewhere where the beginning part of the filename is NOT /my/files/this-dir/probablyduplicate/

use Data::Dumper;
use Webdedup::File;
use File::Find;

my $DEBUG=0;

my $path = "../t-fixture-data/source-general/";

my @path = (

    "/media/nas_khoskin_private/pictures/pictures-20150628/",

#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/",
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/100NCD90/",
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/19450000-rene-bnw-1940s/",
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/20031100-canonA80"

);

# connect to the db on localhost with webdedup and insecure.

use DBI;
use DBD::mysql;

my $dsn="dbi:mysql:webdedup:localhost:3306";

my $dbh;


my $filecount=0;

if ( not $dbh = DBI->connect($dsn,"webdedup","insecure")){
    die "havent't got a handle\n";
};

# get all the files with a certain "root" path.
my $root_path = "/media/nas_khoskin_private/pictures/pictures-20150628/%"; # needs % on the end
my $sth = $dbh->prepare("select * from files where fullfilename like ?");
my $rv  = $sth->execute($root_path);

my $results = {};

for my $row ( $sth->fetchrow_hashref ) {
    $results->{$row->{fullfilename}}={};

    # now see if we can find the same contents_sha , but with a different "root_path"
    my $sth_dups = $dbh->prepare("select * from files where contents_sha = ? and fullfilename not like ? ");

    
    my $rv_dups  = $sth_dups->execute( $row->{contents_sha} , $root_path );
    for my $row_dups ( $sth_dups->fetchrow_hashref ) {
        $results->{$row->{fullfilename}}{$row_dups->{fullfilename}}=1
    }



}



sub get_file {
    my ( $file ) = @_;

    my $sth = $dbh->prepare("select * from files where fullfilename=?");

    my $rv = $sth->execute($file);

    my $ret ={};
    my $count = 0 ;
    for my $row ( $sth->fetchrow_hashref ) {
        die "too many results" if $count > 0;
        $count++;
        $ret = $row
    }

    return $ret;
}


