
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `spotify_graph` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `spotify_graph`;
DROP TABLE IF EXISTS `artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `artists` (
  `artist_id` varchar(64) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `href` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`artist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `people`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `people` (
  `person_id` varchar(64) NOT NULL,
  `person_name` varchar(255) NOT NULL,
  PRIMARY KEY (`person_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `people_edges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `people_edges` (
  `p1` varchar(64) NOT NULL,
  `p2` varchar(64) NOT NULL,
  `person1` varchar(255) DEFAULT NULL,
  `person2` varchar(255) DEFAULT NULL,
  `weight` int DEFAULT NULL,
  `jaccard` decimal(10,6) DEFAULT NULL,
  PRIMARY KEY (`p1`,`p2`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `people_playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `people_playlists` (
  `person_id` varchar(64) NOT NULL,
  `playlist_id` varchar(64) NOT NULL,
  PRIMARY KEY (`person_id`,`playlist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `playlist_tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `playlist_tracks` (
  `playlist_id` varchar(64) NOT NULL,
  `track_id` varchar(64) NOT NULL,
  `added_at` datetime DEFAULT NULL,
  `added_by` varchar(128) DEFAULT NULL,
  `disc_number` int DEFAULT NULL,
  `track_number` int DEFAULT NULL,
  PRIMARY KEY (`playlist_id`,`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `playlists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `playlists` (
  `playlist_id` varchar(64) NOT NULL,
  `name` varchar(512) DEFAULT NULL,
  `description` text,
  `owner_spotify_id` varchar(128) DEFAULT NULL,
  `owner_display_name` varchar(255) DEFAULT NULL,
  `followers` int DEFAULT NULL,
  `href` varchar(512) DEFAULT NULL,
  `snapshot_id` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`playlist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `track_artists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `track_artists` (
  `track_id` varchar(64) NOT NULL,
  `artist_id` varchar(64) NOT NULL,
  PRIMARY KEY (`track_id`,`artist_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `tracks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tracks` (
  `track_id` varchar(64) NOT NULL,
  `name` varchar(512) DEFAULT NULL,
  `album` varchar(512) DEFAULT NULL,
  `release_date` varchar(32) DEFAULT NULL,
  `duration_ms` int DEFAULT NULL,
  `popularity` int DEFAULT NULL,
  `is_local` tinyint(1) DEFAULT NULL,
  `href` varchar(512) DEFAULT NULL,
  PRIMARY KEY (`track_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `v_graph_edges`;
/*!50001 DROP VIEW IF EXISTS `v_graph_edges`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_graph_edges` AS SELECT 
 1 AS `source`,
 1 AS `target`,
 1 AS `weight`,
 1 AS `jaccard`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_graph_nodes`;
/*!50001 DROP VIEW IF EXISTS `v_graph_nodes`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_graph_nodes` AS SELECT 
 1 AS `id`,
 1 AS `label`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_people_artist_overlap`;
/*!50001 DROP VIEW IF EXISTS `v_people_artist_overlap`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_people_artist_overlap` AS SELECT 
 1 AS `person1`,
 1 AS `person1_name`,
 1 AS `person2`,
 1 AS `person2_name`,
 1 AS `shared_artists`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_people_similarity`;
/*!50001 DROP VIEW IF EXISTS `v_people_similarity`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_people_similarity` AS SELECT 
 1 AS `person1`,
 1 AS `person2`,
 1 AS `shared_artists`,
 1 AS `jaccard`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_people_similarity_ids`;
/*!50001 DROP VIEW IF EXISTS `v_people_similarity_ids`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_people_similarity_ids` AS SELECT 
 1 AS `person1_id`,
 1 AS `person2_id`,
 1 AS `person1_name`,
 1 AS `person2_name`,
 1 AS `shared_artists`,
 1 AS `jaccard`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_person_artist`;
/*!50001 DROP VIEW IF EXISTS `v_person_artist`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_person_artist` AS SELECT 
 1 AS `person_id`,
 1 AS `person_name`,
 1 AS `artist_id`,
 1 AS `artist_name`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_person_artist_count`;
/*!50001 DROP VIEW IF EXISTS `v_person_artist_count`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_person_artist_count` AS SELECT 
 1 AS `person_id`,
 1 AS `artist_count`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_person_artist_counts`;
/*!50001 DROP VIEW IF EXISTS `v_person_artist_counts`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_person_artist_counts` AS SELECT 
 1 AS `person_id`,
 1 AS `n_artists`*/;
SET character_set_client = @saved_cs_client;
DROP TABLE IF EXISTS `v_person_track_artist`;
/*!50001 DROP VIEW IF EXISTS `v_person_track_artist`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `v_person_track_artist` AS SELECT 
 1 AS `person_id`,
 1 AS `person_name`,
 1 AS `playlist_id`,
 1 AS `track_id`,
 1 AS `track_name`,
 1 AS `artist_id`,
 1 AS `artist_name`*/;
SET character_set_client = @saved_cs_client;

USE `spotify_graph`;
/*!50001 DROP VIEW IF EXISTS `v_graph_edges`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_graph_edges` AS select `v_people_similarity`.`person1` AS `source`,`v_people_similarity`.`person2` AS `target`,`v_people_similarity`.`shared_artists` AS `weight`,`v_people_similarity`.`jaccard` AS `jaccard` from `v_people_similarity` where ((`v_people_similarity`.`shared_artists` >= 5) or (`v_people_similarity`.`jaccard` >= 0.10)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_graph_nodes`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_graph_nodes` AS select `people`.`person_id` AS `id`,`people`.`person_name` AS `label` from `people` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_people_artist_overlap`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_people_artist_overlap` AS select `a1`.`person_id` AS `person1`,`a1`.`person_name` AS `person1_name`,`a2`.`person_id` AS `person2`,`a2`.`person_name` AS `person2_name`,count(0) AS `shared_artists` from (`v_person_artist` `a1` join `v_person_artist` `a2` on(((`a1`.`artist_id` = `a2`.`artist_id`) and (`a1`.`person_id` < `a2`.`person_id`)))) group by `a1`.`person_id`,`a2`.`person_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_people_similarity`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_people_similarity` AS select `pa1`.`person_name` AS `person1`,`pa2`.`person_name` AS `person2`,count(distinct `pa1`.`artist_id`) AS `shared_artists`,(count(distinct `pa1`.`artist_id`) / (select count(distinct `v_person_artist`.`artist_id`) from `v_person_artist` where (`v_person_artist`.`person_name` in (`pa1`.`person_name`,`pa2`.`person_name`)))) AS `jaccard` from (`v_person_artist` `pa1` join `v_person_artist` `pa2` on(((`pa1`.`artist_id` = `pa2`.`artist_id`) and (`pa1`.`person_id` < `pa2`.`person_id`)))) group by `pa1`.`person_name`,`pa2`.`person_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_people_similarity_ids`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_people_similarity_ids` AS select `p1`.`person_id` AS `person1_id`,`p2`.`person_id` AS `person2_id`,`p1`.`person_name` AS `person1_name`,`p2`.`person_name` AS `person2_name`,`s`.`shared_artists` AS `shared_artists`,`s`.`jaccard` AS `jaccard` from ((`v_people_similarity` `s` join `people` `p1` on((`p1`.`person_name` = `s`.`person1`))) join `people` `p2` on((`p2`.`person_name` = `s`.`person2`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_person_artist`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_person_artist` AS select distinct `v_person_track_artist`.`person_id` AS `person_id`,`v_person_track_artist`.`person_name` AS `person_name`,`v_person_track_artist`.`artist_id` AS `artist_id`,`v_person_track_artist`.`artist_name` AS `artist_name` from `v_person_track_artist` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_person_artist_count`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_person_artist_count` AS select `v_person_artist`.`person_id` AS `person_id`,count(distinct `v_person_artist`.`artist_id`) AS `artist_count` from `v_person_artist` group by `v_person_artist`.`person_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_person_artist_counts`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_person_artist_counts` AS select `v_person_artist`.`person_id` AS `person_id`,count(0) AS `n_artists` from `v_person_artist` group by `v_person_artist`.`person_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!50001 DROP VIEW IF EXISTS `v_person_track_artist`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `v_person_track_artist` AS select `p`.`person_id` AS `person_id`,`p`.`person_name` AS `person_name`,`pt`.`playlist_id` AS `playlist_id`,`pt`.`track_id` AS `track_id`,`t`.`name` AS `track_name`,`ta`.`artist_id` AS `artist_id`,`a`.`name` AS `artist_name` from (((((`people` `p` join `people_playlists` `pp` on((`pp`.`person_id` = `p`.`person_id`))) join `playlist_tracks` `pt` on((`pt`.`playlist_id` = `pp`.`playlist_id`))) join `tracks` `t` on((`t`.`track_id` = `pt`.`track_id`))) join `track_artists` `ta` on((`ta`.`track_id` = `t`.`track_id`))) join `artists` `a` on((`a`.`artist_id` = `ta`.`artist_id`))) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

