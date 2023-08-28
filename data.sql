-- Create the loanbank table if it does not exist
-- This table stores information related to loans, such as license, steam ID, and loan amount.

CREATE TABLE IF NOT EXISTS `loanbank` (
  `license` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,  -- License of the user
  `steam` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,    -- Steam ID of the user
  `discord` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,  -- Discord ID of the user
  `loan` int(11) NOT NULL DEFAULT 0,                                                 -- Loan amount
  `loandate` bigint(60) NOT NULL DEFAULT 0,                                          -- Loan date in UNIX timestamp
  `loanjudge` varchar(255) NOT NULL,                                                 -- The judge who approved the loan
  PRIMARY KEY (`license`)                                                            -- Setting license as the primary key
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;
