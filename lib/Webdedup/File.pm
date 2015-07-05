package Webdedup::File;

#use 5.14.2;
use strict;
# use warnings FATAL => 'all';

=head1 NAME

Webdedup::File

=head1 VERSION

Version 0.01

=cut

our $DEBUG=0;
our $VERSION = '0.01';

use Data::Dumper;
use Image::ExifTool qw(:Public);
use Digest::SHA ;

#my @path = (
#
#    "/media/khoskin/2tb/a_KARL/pictures-201105-main/ali",
##    "/media/nas_khoskin_private/pictures/pictures-20150628/",
##    "/media/khoskin/2tb/a_KARL/pictures-201105-main/",
#);
#
sub get_paths {
    return (

    "/media/khoskin/2tb/a_KARL/pictures-201105-main/ali",
    #"/media/nas_khoskin_private/pictures/pictures-20150628/",
    #"/media/khoskin/2tb/a_KARL/pictures-201105-main/",
    )
};


sub all_mounted {

    # TODO a check that makes sure all drives are mounted.

    return 0 if not -d "/media/khoskin/2tb/a_KARL";
    return 0 if not -d "/media/nas_khoskin_private/pictures/";

    return 1;
}


{

    my $DIGEST_SHA = Digest::SHA->new(512);

    sub getFileDigest {
        my ($class, $filename) = @_;

        return if ! -f $filename;

        # digest resets itself by having the digest read from it , so :-
        $DIGEST_SHA->b64digest;

        $DIGEST_SHA->addfile($filename);
        return $DIGEST_SHA->b64digest;
    }

}

=head2 getUniqueEXIF

<B>Returns

A unique exif OR undef

=cut

sub getUniqueEXIF {
    my ($class, $filename ) = @_ ;

    #ImageInfo dies on MOV files, so :-
    my ( $class, $basename , $file_extension ) = get_picture_file_extension( $filename ) ;

    $file_extension = lc($file_extension);

    my ( $image_info );

    $image_info = ImageInfo($filename);

    #print Dumper ( [ keys %$image_info ] );

    # this program is to work out whether pictures are identical and from the same camera.
    # if we don't have a 'Make' , then we don't know if the picture is
    # a duplicate, so therefore the safe thing to do is to have the full path name
    # and make sure it is classed as a unique picture.
    if ( !$image_info->{'Make'} || $image_info->{'Make'} eq 'XXXXX Corporation' ) {
        return ;
    }

    if ( $image_info->{'Make'} eq 'XXXXX Corporation'
        && ! $image_info->{'FileNumber'}
        && ! $image_info->{'SerialNumber'}
        && ! $image_info->{'FNumber'}
        && ! $image_info->{'ShutterSpeed'}
    ){
        return ; # not enough info
    }

    # This EXIF key has been worked out from what Canon and Nikon cameras provide.
    # It may break with other manufacturers interpretation of EXIF.
    # TODO expand to cater for different camera manufacturers versions of EXIF.
    # It is primarily relying on create time, and image number info to make a unique key.
    my $dateused = replace_bad_chars (   $image_info->{'SubSecCreateDate'}
                    || $image_info->{'CreateDate'}
                    || $image_info->{'DateTimeOriginal'}
                    || $image_info->{'ModifyDate'}
                    || $image_info->{'FileModifyDate'} );

    my ( $year , $month, $day ) = $dateused =~ /^(\d{4})(\d{2})(\d{2})_/;
    if ( ! $year || ! $month || ! $day ) {
        return ;
    }

    my $uniqkey  = $dateused ;
    $uniqkey .= "__" .( $image_info->{'Make'} ) ;
    $uniqkey .= "__" .( $image_info->{'FileNumber'} || $image_info->{'SerialNumber'} || "nonumber" ) ;
    $uniqkey .= "__f".( $image_info->{'FNumber'} || "nofnumber" ) ;
    $uniqkey .= "__s".( $image_info->{'ShutterSpeed'} || "noshutterspeed" ) ;

    $uniqkey .= ".$file_extension";
    $uniqkey = replace_bad_chars( $uniqkey);

    return {
        exif_day    => $day,
        exif_month  => $month,
        exif_year   => $year,
        exif_string => $uniqkey,
    };

}

=head2 replace_bad_chars

=cut

sub replace_bad_chars {
    my ($txt) = @_;

    $txt =~ s/://g;
    $txt =~ s/ /_/g;
    $txt =~ s/\//--/g;
    $txt =~ s/\.+/\./g;

    return $txt;
}

=head2 get_picture_file_extension

=cut

sub get_picture_file_extension {

    my ( $filename , $match_avi_n_mov )  = @_;

    # select whether we are matching image-files OR image-and-movie-files
    my $regex =  $match_avi_n_mov ? '(.*\/)(.+)(\.jpg|\.jpeg|\.png|\.mov|\.avi)\z' : '(.*\/)(.+)(\.jpg|\.jpeg|\.png)\z';

    if ( my ($path , $basename, $file_extension) = $filename =~ m/$regex/i ){
        return $path , $basename, $file_extension;
    }

    return;
}



sub is_valid_shortfilename {

    my ($class, $shortfilename ) = @_; 

    return 0 if $shortfilename eq ".dedup.storable";
    return 0 if $shortfilename eq "Thumbs.db";
    return 0 if $shortfilename eq "ZbThumbnail.info";
    return 0 if $shortfilename eq ".DS_Store";
    return 0 if $shortfilename =~ /\.CTG$/;
    return 0 if $shortfilename =~ /\.html$/i;
    return 0 if $shortfilename =~ /\.lnk$/i;
    return 0 if $shortfilename =~ /\.ini$/i;
    return 0 if $shortfilename =~ /\.DAT$/;

    return 1;

}

{
    use DBI;
    use DBD::mysql;

    my $dsn="dbi:mysql:webdedup:localhost:3306";

    my $dbh;

    if ( not $dbh = DBI->connect($dsn,"webdedup","insecure")){
        die "havent't got a handle\n";
    };

    sub get_dbh {
        return $dbh;
    }

    sub select_file {
        my ( $class, $file ) = @_;

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
        my ( $class, $record ) = @_;

        print "DEBUG : INSERT $record->{fullfilename}\n" if $DEBUG;

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
        my ( $class, $record ) = @_;

        print "DEBUG : UPDATE $record->{fullfilename}\n" if $DEBUG;

        my $fields = '';
        my @values = ();
        for my $field ( keys %$record ) {
            next if $field eq 'fullfilename';
            next if $field eq 'file_id';

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


    sub delete_file_id {
        my ( $class, $file_id ) = @_;

        my $sth = $dbh->prepare("delete from files where file_id=?");

        my $rv = $sth->execute($file_id);
    }


}

#=head2 destination_filename_exif
#
#=cut
#
#sub destination_filename_exif {
#    my ($self) = @_;
#    return "/".$self->year_exif."/".$self->year_exif.$self->month_exif."/".$self->year_exif.$self->month_exif.$self->day_exif."/".$self->unique_exif;
#
#}
#
#=head2 destination_filename_sha
#
#=cut
#
#sub destination_filename_sha {
#    # need to get the year, month, day from the other files in the same source directory.
#
#}

1;
