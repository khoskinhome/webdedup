#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Webdedup::File;
use File::Find;

my $DEBUG=0;
my $FORCE_UPDATE=0;

die "need all disks mounted" if ! Webdedup::File->all_mounted;

# this script populates the "files" table from the filing system.

#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/100NCD90/",
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/19450000-rene-bnw-1940s/",
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/20031100-canonA80",

&delete_old_files_from_db();

my $filecount=0;
find ( \&testfile, Webdedup::File->get_paths );
print "$filecount\n";


sub testfile {
    my $filename = $File::Find::name; # symlinks resolved.

    return if -d $filename;

    my($directory, $shortfilename) = $filename =~ m/(.*\/)(.*)$/;

    return if not Webdedup::File->is_valid_shortfilename( $shortfilename );

    $filecount++;
    print "$filecount\n" if $filecount % 1000 == 0;

    my $dbrecord = Webdedup::File->select_file($filename);

    my ( undef, undef, undef, undef, undef, undef, undef, $filesize, undef, $mtime )
        =  stat($filename);

    return if
        exists $dbrecord->{mtime}
        && $dbrecord->{mtime} >= $mtime
        && not $FORCE_UPDATE;

    my $exifhsh = Webdedup::File->getUniqueEXIF($filename);
    my $sha     = Webdedup::File->getFileDigest($filename);

    my $filetype = defined $exifhsh ? "picture" : "other" ;

    my $record = {
        fullfilename  => $filename,
        shortfilename => $shortfilename,
        filetype      => $filetype,
        filesize      => $filesize,
        contents_sha  => $sha,
        mtime         => $mtime,
        mp3_string    => '',
        defined $exifhsh ? %$exifhsh : () ,
    };

    if ( ! exists $dbrecord->{fullfilename} ) {
        print "$filecount : INSERT $record->{fullfilename}\n";
        Webdedup::File->insert_file ( $record );
    } else {
        print "$filecount : UPDATE $record->{fullfilename}\n";
        Webdedup::File->update_file ( $record );
    }
}


sub delete_old_files_from_db {
    my ( $file ) = @_;

    my $dbh = Webdedup::File->get_dbh();

    my $sth = $dbh->prepare("select * from files ");

    my $rv = $sth->execute();

    my $count = 0;
    while (  my $row = $sth->fetchrow_hashref ) {
        $count ++ ;
        print "$count\n" if $count % 1000 == 0;

        if ( not Webdedup::File->is_valid_shortfilename( $row->{shortfilename} )
            || ! -f $row->{fullfilename}
        ){
            print "delete  $row->{shortfilename}\n";
            Webdedup::File->delete_file_id( $row->{file_id} );
            next;
        }

        #my ( undef, undef, undef, undef, undef, undef, undef, $filesize, undef, $mtime ) =  stat($row->{fullfilename});







    }

    print "$count\n";

}


