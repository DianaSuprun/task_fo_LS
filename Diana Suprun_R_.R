library(validate)
library(dplyr)
library(validatetools)
library(zoo)

#<- use packeges
inputData <- read.csv(file="C:/Users/Diana/Desktop/another test/data.csv", header = TRUE, sep = ",")
test_data <- data.frame(inputData)
test_data <- test_data%>%
  dplyr:: mutate(own_id = row_number())
#Created rules
myrules <- validator( "Whether quantity is negative:" = Quantity > 0,
                      "Whether UnitPrice is negative:" = UnitPrice > 0,
                      "Whether N/A exists:" = !is.na(CustomerID),
                      "Whether all rows are complete:" = is_complete(InvoiceNo,StockCode,Description,Quantity,InvoiceDate,UnitPrice,Country))
out <- confront(test_data, myrules, key = "own_id")
summary(out)
#transform to dataframe
dout <- as.data.frame(out)
#find only rows with mistakes
dErrors <- dout%>%
  dplyr::filter(!value == TRUE)
#VALIDATE DATA
new_data <- anti_join(test_data, dErrors, by = "own_id")
#Part 3 of task 2 -> creating a t=new table
selected_data <- new_data%>%
  arrange(InvoiceDate, InvoiceNo) %>%
  group_by(CustomerID) %>%
  mutate(InvoiceNumber = row_number())

# Compute the total price of each invoice and the cumulative sum of the total price
selected_data <- selected_data %>%
  mutate(InvoiceTotalPrice = Quantity * UnitPrice,
         CumulativeSum = cumsum(InvoiceTotalPrice))

# Find the previous invoice number for each customer by invoice date
selected_data <- selected_data %>%
  group_by(CustomerID) %>%
  mutate(Prev_InvoiceNo = lag(InvoiceNo))

# Select the required columns
result <- selected_data %>%
  select(CustomerID, InvoiceNo, InvoiceDate, InvoiceNumber, InvoiceTotalPrice, Prev_InvoiceNo, CumulativeSum)
#TOP 15 ROWS OF DATA FRAME FROM 3 PART OF TASK 2
new_data_frame <- head(result,15)


#PART 4 OF TAKS 2
daily_stats <- selected_data %>%
  group_by(InvoiceDate) %>%
  summarize(TotalPrice_by_Day = sum(UnitPrice),
            TotalPrice_by_Week = rollapplyr(UnitPrice, 7,  sum, align = "right", fill = NA),
            TotalPrice_by_Month = rollapplyr(UnitPrice,30,sum, align = "right", fill = NA),
            Percentage_of_TwoItems = sum(Quantity >= 2) / n(),
            Transactions = n(),
            Refunds = sum(Quantity < 0),
            RefundRate_by_Payments = sum(Quantity < 0) / n(),
            RefundRate_by_TotalPrice = sum(UnitPrice[Quantity < 0]) / sum(UnitPrice))%>%
  replace_na(list(RollingSum7Days = 0, RollingSum30Days = 0))

#RESULT OF PART 4 OF TAKS 2
daily_stats
