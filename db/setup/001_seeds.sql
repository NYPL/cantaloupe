CREATE DATABASE local_filestore_db;
USE local_filestore_db;

# ************************************************************
# Sequel Ace SQL dump
# Version 20019
#
# https://sequel-ace.com/
# https://github.com/Sequel-Ace/Sequel-Ace
#
# Host: localhost (MySQL 8.0.27)
# Database: filestore
# Generation Time: 2021-12-29 19:16:39 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
SET NAMES utf8mb4;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE='NO_AUTO_VALUE_ON_ZERO', SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


# Dump of table file_store
# ------------------------------------------------------------

DROP TABLE IF EXISTS `file_store`;

CREATE TABLE `file_store` (
  `ID` int unsigned NOT NULL AUTO_INCREMENT,
  `FILE_NAME` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `CHECKSUM` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL DEFAULT '',
  `FILE_ID` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT '',
  `TIME_STAMP` timestamp NOT NULL,
  `TYPE` varchar(2) NOT NULL DEFAULT '',
  `W` float DEFAULT NULL,
  `H` float DEFAULT NULL,
  `STATUS` tinyint unsigned NOT NULL,
  `SRC` varchar(4) DEFAULT NULL,
  `IID` tinyint unsigned NOT NULL,
  `UUID` varchar(45) NOT NULL DEFAULT '',
  `CDATE` date NOT NULL,
  `SIZE` bigint unsigned DEFAULT NULL,
  `QUAR` tinyint(1) NOT NULL,
  `last_check` date DEFAULT NULL,
  `fault` tinyint(1) unsigned zerofill DEFAULT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

LOCK TABLES `file_store` WRITE;
/*!40000 ALTER TABLE `file_store` DISABLE KEYS */;

INSERT INTO `file_store` (`ID`, `FILE_NAME`, `CHECKSUM`, `FILE_ID`, `TIME_STAMP`, `TYPE`, `W`, `H`, `STATUS`, `SRC`, `IID`, `UUID`, `CDATE`, `SIZE`, `QUAR`, `last_check`, `fault`)
VALUES
	(323550,'489870u.tif','hqhZPIwl2wa1xaJ2Ox0uGA','489870','2008-11-13 22:22:45','u',3181,2545,4,'1',1,'AB145C4C-5E73-11DD-A95F-75DC9956CD08','2003-02-20',24293959,0,'2011-08-08',1),
	(749347,'01sccdvu.tif','xFKWG8r8Jri5Jw+Qx7xj9g','01sccdv','2008-11-16 01:51:58','u',2386,1587,5,'1',1,'E536737A-60F2-11DD-A183-93F19956CD08','1997-09-26',9595668,0,'2021-05-13',0),
	(4733220,'489870r.jpg','r5g3jeQ+hBErwTglKgHDqQ','489870','2008-09-27 08:18:03','r',300,243,4,'1',1,'5D439652-8C8D-11DD-ACD9-2E989956CD08','2004-08-04',NULL,0,'2021-12-09',0),
	(5109966,'01sccdvr.jpg','QbujjQ9L/7QdSBMnWJ5C2w','01sccdv','2008-09-28 21:28:03','r',199,300,5,'1',1,'E1C7B844-8DC4-11DD-AA33-95F59956CD08','2005-11-05',NULL,0,'2021-04-19',0),
	(5659499,'489870t.gif','qLVMPdOVXvx7tFNUhGx5aA','489870','2008-10-02 21:39:24','t',150,122,4,'1',1,'1B1BD07A-90EB-11DD-B6FB-85CE9956CD08','2004-08-03',NULL,0,'2020-05-27',0),
	(6036183,'01sccdvt.gif','327VAxAYC3PlLzSPYlgQOw','01sccdv','2008-10-04 10:02:25','t',99,150,5,'1',1,'0F5574A8-921C-11DD-8C62-0CEC9956CD08','2005-11-05',NULL,0,NULL,NULL),
	(6464990,'489870w.jpg','CRkk7U+Zfks7Lrz8EKm2yg','489870','2008-10-07 03:02:01','w',760,616,4,'1',1,'CF5F4F54-943C-11DD-8A82-8DCF9956CD08','2004-08-04',NULL,0,NULL,NULL),
	(6841819,'01sccdvw.jpg','tnJSkswM/FIjJCk/MgXsig','01sccdv','2008-10-08 20:04:02','w',505,760,5,'1',1,'BD4054CC-9594-11DD-ADBA-ADFC9956CD08','2005-11-05',NULL,0,NULL,NULL),
	(10417451,'01sccdvf.jpg','n8fdNj8fFtY9qehLO09rGg','01sccdv','2013-05-12 12:17:20','f',93,140,5,'NDNP',1,'232356C2-BB1F-11E2-92D1-9A6B957D6753','2013-05-12',4000,0,NULL,NULL),
	(11281558,'489870f.jpg','wplGjYBKzdzVsDvvuhzuNA','489870','2013-05-16 18:43:59','f',173,140,4,'NDNP',1,'CEF83A3C-BE79-11E2-9FC8-805A957D6753','2013-05-16',7176,0,NULL,NULL),
	(13236117,'01sccdvb.jpg','GXxi9m5efickukCslmM88A','01sccdv','2013-06-01 13:55:30','b',100,100,5,'NDNP',1,'2243866C-CAE4-11E2-80F9-F946957D6753','2013-06-01',3230,0,NULL,NULL),
	(13396315,'01sccdvb.jpg','GXxi9m5efickukCslmM88A','01sccdv','2013-06-03 12:38:30','b',100,100,5,'NDNP',1,'B4BC0DB0-CC6B-11E2-8207-62B6957D6753','2013-06-03',3230,0,NULL,NULL),
	(13937155,'489870b.jpg','RO/QnQ2NGul4sneHuyCwtA','489870','2013-06-07 12:58:03','b',100,100,4,'NDNP',1,'1762D6D6-CF93-11E2-B11B-E47A957D6753','2013-06-07',3404,0,NULL,NULL),
	(31830976,'01SCCDVr.jpg','256e29861e6fe6cd4ce766c5f49dab78','01SCCDV','2021-05-24 18:06:10','r',196,299,4,'DGTL',2,'CAEB566F-8F27-4E0F-A50C-B57C12A2E2AC','2021-05-24',74168,0,NULL,NULL),
	(31830977,'01SCCDVb.jpg','fbd1a2cbbae9e54354397b3b32d4470f','01SCCDV','2021-05-24 18:06:11','b',100,100,4,'DGTL',2,'EB3D4383-CBB6-467B-A1EA-231F2435C90F','2021-05-24',12995,0,NULL,NULL),
	(31830978,'01SCCDVt.gif','e5ac3b2c4695fdae010eaa4bc2b06cac','01SCCDV','2021-05-24 18:06:11','t',98,149,4,'DGTL',2,'1EEA961A-E640-4921-9836-29EEF7FD33F5','2021-05-24',16036,0,NULL,NULL),
	(31830979,'01SCCDVf.jpg','988762f47622eeb153ba22b0dc68a7d3','01SCCDV','2021-05-24 18:06:11','f',91,139,4,'DGTL',2,'51320851-7A4F-452D-8CC3-852CF44967E8','2021-05-24',24613,0,NULL,NULL),
	(31830980,'01SCCDVw.jpg','af8f025dbcfe342df15a1aa9e1f2485d','01SCCDV','2021-05-24 18:06:11','w',498,759,4,'DGTL',2,'098750E6-764C-4A1A-8DF9-AF84A4CA6019','2021-05-24',408986,0,NULL,NULL),
	(31830981,'01SCCDVj.jp2','05e66bfae7ca62edcbb8fac65dfb0a3d','01SCCDV','2021-05-24 18:06:12','j',3814,5810,4,'DGTL',2,'16A509F6-D312-4779-9C0A-ED2ECF37707F','2021-05-24',22297561,0,NULL,NULL),
	(31830982,'01SCCDVs.tif','41172418380fcb1b3c753293c427257d','01SCCDV','2021-05-24 18:06:14','s',3814,5810,4,'DGTL',2,'1675CC95-9E3B-46ED-9DB1-DFE0FE52F538','2021-05-24',66537500,0,NULL,NULL),
	(31830985,'01SCCDVu.tif','b1833fee44312b386e4658753ff5980b','01SCCDV','2021-05-24 18:06:42','u',8706,11605,4,'DGTL',2,'2AF9F344-B92D-4C18-8CD1-F4F2E94B377F','2021-05-24',303428924,0,NULL,NULL);

/*!40000 ALTER TABLE `file_store` ENABLE KEYS */;
UNLOCK TABLES;



/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
