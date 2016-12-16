library(dplyr)
library(ggplot2)

# after removing first line of the csv file

data <- read.csv('LoanStats_2016Q3.csv', stringsAsFactors = F, skip = 1)
# last two rows are irrelevant, remove them
dat <- head(dat, -2)

dim(data)
names(data)

# select columns of interest
mydata <- select(data, 
                 grade, sub_grade, loan_status, funded_amnt, term, int_rate, installment, 
                 annual_inc, 
                 dti, 
                 earliest_cr_line, revol_util, inq_last_12m, tot_cur_bal,
                 purpose, emp_title, emp_length, addr_state)

# create some new columns monthly income
mydata <- mutate(mydata, monthly_inc = annual_inc/12, dti_lc = installment/monthly_inc, lcd_totd = dti_lc/(dti/100))

# check data structures of all the columns
str(dat)

# convert term (chr) to int, emp_length (chr) to int, int_rate to float
mydata$term <- as.numeric(substr(mydata$term, 1,3))
mydata$emp_length <- as.numeric(substr(mydata$emp_length, 1,2))
mydata$int_rate <- as.numeric(gsub("%", "", mydata$int_rate)) / 100
mydata$revol_util <- as.numeric(gsub("%", "", mydata$revol_util)) / 100
mydata$earliest_cr_line <- as.numeric(difftime(Sys.Date(), as.Date(paste("01-",mydata$earliest_cr_line,sep=''), format = "%d-%b-%Y")),units = 'days')/365


# there are extremely high income people using Lending Club to borrow money. But the job title doesn't support it's a valid one, and therefore likely a bad data
max(mydata$annual_inc)
mydata[which(mydata$annual_inc == max(mydata$annual_inc)),]

# Let's see how other high income ($1m annual income) people's profiles look like
hi_profile <- mydata[which(mydata$annual_inc > 1000000),]$emp_title

# Only consider annual income < 2m
mydata <- filter(mydata, annual_inc < 500000)

# What is the range of salary? Do high income borrowers tend to get funded more?
p <- ggplot(mydata, aes(annual_inc, funded_amnt))
p <- p + geom_point(aes(colour = grade)) 
p <- p + labs(title = 'annual inc vs. funded amnt')
p + geom_smooth()


