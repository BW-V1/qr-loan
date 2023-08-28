CREATE TABLE IF NOT EXISTS `loanbank` (
  `license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `steam` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `discord` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `loan` int(11) NOT NULL DEFAULT 0,
  `loandate` bigint(60) NOT NULL DEFAULT 0,
  `loanjudge` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;