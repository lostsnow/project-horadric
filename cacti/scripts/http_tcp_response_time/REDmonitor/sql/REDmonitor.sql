#
# Table structure for table REDmonitor
#

DROP TABLE IF EXISTS `REDmonitor`;
CREATE TABLE `REDmonitor` (
  `Id` int(11) NOT NULL auto_increment,
  `date` datetime default '0000-00-00 00:00:00',
  `site` varchar(100) default NULL,
  `statuscode` int(11) default NULL,
  `responsetime` int(11) default NULL,
  `statuscount` int(11) default '0',
  PRIMARY KEY  (`Id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;