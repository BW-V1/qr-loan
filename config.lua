--AT_CourtSystem

Config = {}
Config.WEEBHOOK = ''
Config.MaxLoan = 100000
Config.LoanTime = 14 -- Days
Config.LoanProfit = 1.20 -- 1.20 = +20% (قرض 100 الف يصير يطلب تسديد 120 الف)

Config.LoansMenu = {
    { value = '25000', label = '$قرض بقيمة 25,000' },
    { value = '50000', label = '$قرض بقيمة 50,000'},
    { value = '75000', label = '$قرض بقيمة 75,000'},
    { value = '100000', label = '$قرض بقيمة 100,000'},
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