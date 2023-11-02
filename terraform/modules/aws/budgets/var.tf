variable name {
	type = string
	description = "Name of the budget"
	default = "Default Budgets"
}

variable budget_type {
	type = string
	default = "COST"
	description = "Type of the budget"
}

variable limit_amount {
	type = string
	description = "The budget limit amount"
}

variable limit_unit {
	type = string
	default = "USD"
	description = "The limit currency"
}

variable time_unit {
	type = string
	default = "MONTHLY"
	description = "The time unit for budget calculations"
}

variable include_credit {
	type = bool
	default = false
	description = "Include credit in budget calculations"
}

variable include_discount {
	type = bool
	default = false
	description = "Include discount in budget calculations"
}

variable include_other_subscription {
	type = bool
	default = false
	description = "Include other subscriptions in budget calculations"
}

variable include_recurring {
	type = bool
	default = false
	description = "Include recurring costs in budget calculations"
}

variable include_refund {
	type = bool
	default = false
	description = "Include refund costs in budget calculations"
}

variable include_subscription {
	type = bool
	default = false
	description = "Include subscription in budget calculations"
}

variable include_support {
	type = bool
	default = false
	description = "Include support in budget calculations"
}

variable include_tax {
	type = bool
	default = false
	description = "Include tax in budget calculations"
}

variable include_upfront {
	type = bool
	default = false
	description = "Include upfront payments in budget calculations"
}

variable use_blended {
	type = bool
	default = false
	description = "Use blended costs costs in budget calculations"
}

variable subscriber_email_addresses {
	type = list(string)
	description = "Email addresses for budget alerts"
	default = [
		"jrgns@aex.co.za" # TODO More?
	]
}
