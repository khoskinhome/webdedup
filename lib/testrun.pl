#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;
use Webdedup::File;
use File::Find;

my $DEBUG=0;

my $path = "../t-fixture-data/source-general/";

my @path = (
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/",
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/100NCD90/",
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/19450000-rene-bnw-1940s/",
    "/media/khoskin/2tb/a_KARL/pictures-201105-main/pictures-201105-backedup/00000000-checked/20031100-canonA80"

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


find ( \&testfile, @path );


# so record the file mtime to see if we are going to update the exif or mp3 info.
# my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
#    $atime,$mtime,$ctime,$blksize,$blocks)
#    = stat($filename);


sub testfile {
    my $filename = $File::Find::name; # symlinks resolved.

    return if -d $filename;

    $filecount++;

    my($directory, $shortfilename) = $filename =~ m/(.*\/)(.*)$/;

    my $dbrecord = get_file($filename);

    my ( undef, undef, undef, undef, undef, undef, undef, $filesize, undef, $mtime )
        =  stat($filename);

    ### $mtime ++; # TODO rm this hack for testing

    if ( exists $dbrecord->{mtime}
          && $dbrecord->{mtime} >= $mtime ){
        return;
    }

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

    if ( ! exists $dbrecord->{mtime} ) {
        insert_file ( $record );
    } else {
        update_file ( $record );
    }

}

=head2 get_file

gets a single "file" record.

will die if the input gives back more than one record.

=cut 

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


sub insert_file {
    my ( $record ) = @_;

    print "$filecount : INSERT $record->{fullfilename}\n";

    my $fields = '';
    my $values = '';
    my @values =() ;
    for my $field ( keys %$record ) {
        $fields .= ',' if $fields;
        $values .= ',' if $values;
        $fields .= "$field";
        $values .= "?";
        push @values, $record->{$field};
    }

    my $sql = "insert into files ($fields) VALUES ( $values )";
    print $sql."\n" if $DEBUG;

    my $sth = $dbh->prepare( $sql );

    my $rv = $sth->execute(@values);

}


sub update_file {
    my ( $record ) = @_;

    print "$filecount : UPDATE $record->{fullfilename}\n";

    my $fields = '';
    my @values = ();
    for my $field ( keys %$record ) {
        next if $field eq 'fullfilename';

        $fields .= ',' if $fields;
        $fields .= "$field=?";
        push @values, $record->{$field};
    }

    push @values , $record->{fullfilename};

    my $sql = "update files set $fields where fullfilename=? ";
    print $sql."\n" if $DEBUG;

    my $sth = $dbh->prepare($sql);

    my $rv = $sth->execute(@values);

}
