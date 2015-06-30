-- MySQL dump 10.13  Distrib 5.6.19, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: webdedup
-- ------------------------------------------------------
-- Server version	5.6.19-1~exp1ubuntu2

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `files`
--

DROP TABLE IF EXISTS `files`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `files` (
  `file_id` int(11) NOT NULL AUTO_INCREMENT,
  `fullfilename` varchar(700) NOT NULL,
  `shortfilename` varchar(256) NOT NULL,
  `filetype` varchar(15) DEFAULT NULL,
  `contents_sha` varchar(512) DEFAULT NULL,
  `mp3_string` varchar(256) DEFAULT NULL,
  `exif_string` varchar(256) DEFAULT NULL,
  `is_censored` tinyint(1) DEFAULT NULL,
  `rating` tinyint(3) unsigned DEFAULT NULL,
  `is_marked_for_deletion` tinyint(1) DEFAULT NULL,
  `exif_name` varchar(48) DEFAULT NULL,
  PRIMARY KEY (`file_id`),
  UNIQUE KEY `fullfilename` (`fullfilename`),
  KEY `in_contents_sha` (`contents_sha`),
  KEY `in_mp3_string` (`mp3_string`),
  KEY `in_exif_string` (`exif_string`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `files`
--

LOCK TABLES `files` WRITE;
/*!40000 ALTER TABLE `files` DISABLE KEYS */;
/*!40000 ALTER TABLE `files` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `searchpaths`
--

DROP TABLE IF EXISTS `searchpaths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `searchpaths` (
  `searchpath_id` int(11) NOT NULL AUTO_INCREMENT,
  `fullpath` varchar(1024) NOT NULL,
  `priority` int(11) NOT NULL,
  PRIMARY KEY (`searchpath_id`),
  KEY `in_fullpath` (`fullpath`(767))
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `searchpaths`
--

LOCK TABLES `searchpaths` WRITE;
/*!40000 ALTER TABLE `searchpaths` DISABLE KEYS */;
/*!40000 ALTER TABLE `searchpaths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tagfilemap`
--

DROP TABLE IF EXISTS `tagfilemap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tagfilemap` (
  `tagfilemap_id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) NOT NULL,
  `file_id` int(11) NOT NULL,
  PRIMARY KEY (`tagfilemap_id`),
  UNIQUE KEY `uc_tagfileid` (`tag_id`,`file_id`),
  KEY `in_tag_id` (`tag_id`),
  KEY `in_file_id` (`file_id`),
  CONSTRAINT `tagfilemap_ibfk_1` FOREIGN KEY (`tag_id`) REFERENCES `tags` (`tag_id`),
  CONSTRAINT `tagfilemap_ibfk_2` FOREIGN KEY (`file_id`) REFERENCES `files` (`file_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tagfilemap`
--

LOCK TABLES `tagfilemap` WRITE;
/*!40000 ALTER TABLE `tagfilemap` DISABLE KEYS */;
/*!40000 ALTER TABLE `tagfilemap` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `tag_id` int(11) NOT NULL AUTO_INCREMENT,
  `tagname` varchar(40) NOT NULL,
  PRIMARY KEY (`tag_id`),
  KEY `in_tagname` (`tagname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `bcrypt_hash` varchar(1024) NOT NULL,
  `username` varchar(50) NOT NULL,
  `groupname` varchar(15) DEFAULT NULL,
  `can_view_censored` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  KEY `in_username` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2015-06-30 22:43:53
