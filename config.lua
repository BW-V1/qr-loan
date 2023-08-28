--AT_CourtSystem

Config = {}

-- Webhook URL for notifications
-- Make sure to replace this with your actual webhook URL
Config.WEEBHOOK = Config.WEEBHOOK or ''  -- Empty string as default
if Config.WEEBHOOK == '' then
    print("Warning: Webhook URL is empty. Notifications will not be sent.")
end

-- Maximum loan amount
Config.MaxLoan = Config.MaxLoan or 100000  -- 100000 as default
-- Loan time in days
Config.LoanTime = Config.LoanTime or 14  -- 14 days as default
-- Loan profit rate
-- For example, 1.20 means +20% profit (i.e., a loan of 100,000 would require repayment of 120,000)
Config.LoanProfit = Config.LoanProfit or 1.20  -- 1.20 as default

-- Available loan options in the menu
Config.LoansMenu = {
    { value = '25000', label = '$قرض بقيمة 25,000' },
    { value = '50000', label = '$قرض بقيمة 50,000' },
    { value = '75000', label = '$قرض بقيمة 75,000' },
    { value = '100000', label = '$قرض بقيمة 100,000' },
}

Config.ModelSpawns = {
    ["Bank"] = {
        ["name"] = "Bank",
        ["take"] = "Create Lone",
        ["pay"] = "loan repayment",
        ["icon"] = "fa-solid fa-cash-register",
        ["model"] = "amsp_robsdgunsmith_males_01",
        ["coords"] = vector3(1292.94, -1304.62, 77.04),
        ["heading"] = 321.8145,
    },
}
Config.text = {
    ["PayLoanMenu"] = {
        ["input"] = "Your current loan $: ",
        ["label"] = 'the amount',
        ["label2"] = "Are You Sure ?",
        ["description"] = 'Amount to be paid',
    },
    ["CrateLoanMenu"] = {
        ["input2"] = "Create a new loan",
        ["labels"] = 'Loan Amount',
        ["labels2"] = "Are You Sure ?", 
    },
}

Config.Notify = {
    ["error"] = {
        ["error1"] = "Wrong Entry",
        ["error2"] = 'Was Canceled',
        ["error3"] = 'The player has a loan that has not been paid before.',
        ["error4"] = 'An error occurred, the player cannot be found',
    },
    ["success"] = {
        ["success1"] = 'The loan is deposited into your account...',
    },
}

function comma_value(n)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end