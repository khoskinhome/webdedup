




select count(*) , fullfilename , distinct(contents_sha), sum(filesize), filesize FROM files ;


select distinct(contents_sha), count(contents_sha), sum(filesize),filesize FROM files group by contents_sha having count(contents_sha)>1 order by sum(filesize);










root_path = /media/nas_khoskin_private/pictures/pictures-20150628/%


select 

    * 

from 

    files 

where 

    fullfilename not like root_path 

    and contents_sha not in 
        ( select
            contents_sha 
          from 
            files 
          where 
            fullfilename like root_path 
        )


###########

select * from

    files

where 

    fullfilename not like '/media/nas_khoskin_private/pictures/pictures-20150628/%'

    and contents_sha not in
        ( select
            contents_sha
          from
            files
          where
            fullfilename like '/media/nas_khoskin_private/pictures/pictures-20150628/%'
        )

#############

select * from

    files

where 

    fullfilename like '/media/nas_khoskin_private/pictures/pictures-20150628/%'

    and contents_sha not in
        ( select
            contents_sha
          from
            files
          where
            fullfilename not like '/media/nas_khoskin_private/pictures/pictures-20150628/%'
        )

#############






CREATE TABLE files (
    file_id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,

    fullfilename           varchar( 700 ) NOT NULL UNIQUE,
    shortfilename          varchar( 256 ) NOT NULL,
    filetype               enum ( 'other', 'audio','video','picture','text','binary' ) ,
    filesize               bigint not null,
    contents_sha           varchar( 512 ) NOT NULL,

    mp3_string             varchar( 256 ),

    exif_string            varchar( 700 ),
    exif_year              varchar (5),
    exif_month             varchar (3),
    exif_day               varchar (3),

    mtime                  bigint NOT NULL,

    is_censored            boolean not null DEFAULT 0,

    rating                 TINYINT UNSIGNED DEFAULT 3,

    is_marked_for_deletion boolean not null DEFAULT 0,

    INDEX in_contents_sha (contents_sha),
    INDEX in_mp3_string   (mp3_string),
    INDEX in_exif_string  (exif_string)

);


