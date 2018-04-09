StaticPopupDialogs["WARNING_AUDIT_HIST_CLEAR"] = {
    text = "Warning: this will delete all audit history data.  Are you sure you want to do this?",
    button1 = "Yes",
    button2 = "Cancel",
    OnAccept = function (self)
        GB_Message("Clearing Audit History...")
        GB_AuditHistory = {}
    end,
    OnUpdate = nil,
    hasMoneyInputFrame = false,
    hasEditBox = false,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true
}