

DROP DATABASE webdedup;

CREATE DATABASE IF NOT EXISTS webdedup;

use webdedup;

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

CREATE TABLE tags (
    tag_id  integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tagname varchar (40) NOT NULL,

    is_person boolean not null DEFAULT 0,
    is_place  boolean not null DEFAULT 0,
    is_event  boolean not null DEFAULT 0,

    INDEX in_tagname (tagname)
);

CREATE TABLE tagfilemap (
    tagfilemap_id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    tag_id  integer NOT NULL,
    file_id integer NOT NULL,


    FOREIGN KEY (tag_id) REFERENCES tags(tag_id),
    FOREIGN KEY (file_id) REFERENCES files(file_id),
    INDEX in_tag_id (tag_id),
    INDEX in_file_id (file_id),
    CONSTRAINT uc_tagfileid UNIQUE ( tag_id, file_id)
);

CREATE TABLE users (
    user_id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    bcrypt_hash       varchar( 1024 ) NOT NULL,
    username          varchar( 50 )   NOT NULL,
    groupname         ENUM ( 'admin' , 'user' ),
    can_view_censored boolean,
    INDEX in_username (username)
);

CREATE TABLE searchpaths (
    searchpath_id integer NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fullpath varchar(1024) NOT NULL,
    priority integer NOT NULL,
    INDEX in_fullpath (fullpath)
);

CREATE USER 'webdedup'@'localhost'
IDENTIFIED BY 'insecure'
;

GRANT ALL ON webdedup.* TO 'webdedup'@'localhost';




