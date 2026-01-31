package com.antigravity.expensetracker.service;

import com.antigravity.expensetracker.model.EmailLog;
import com.antigravity.expensetracker.model.Expense;
import com.antigravity.expensetracker.repository.ExpenseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class EmailParsingService {

    @Autowired
    private ExpenseRepository expenseRepository;

    @Autowired
    private BillService billService;

    @Autowired
    private com.antigravity.expensetracker.repository.BillRepository billRepository;

    @Autowired
    private com.antigravity.expensetracker.controller.EmailParsingController emailParsingController;

    public void parseAndCreateExpense(EmailLog emailLog) {
        String rawSubject = emailLog.getSubject();
        String rawBody = emailLog.getBody();
        String normalizedSubject = rawSubject.replace('\u00A0', ' ').replaceAll("\\s+", " ");
        String extractionMethod = "Open AI";

        System.out.println("DEBUG Parsing Subject: [" + normalizedSubject + "]");

        Expense expense = null;

        // 1. Primary Method: Gemini API
        try {
            com.antigravity.expensetracker.dto.EmailParseRequest request = new com.antigravity.expensetracker.dto.EmailParseRequest();
            request.setSubject(normalizedSubject);
            request.setBody(rawBody);
            request.setSender(emailLog.getSender());

            org.springframework.http.ResponseEntity<com.antigravity.expensetracker.dto.ExpenseExtractionResponse> response = emailParsingController
                    .parseEmail(request);

            if (response.getStatusCode().is2xxSuccessful() && response.getBody() != null
                    && !response.getBody().isError()) {
                com.antigravity.expensetracker.dto.ExpenseExtractionResponse aiBody = response.getBody();
                expense = new Expense();
                expense.setAmount(aiBody.getAmount());
                expense.setMerchant(aiBody.getMerchant() != null ? aiBody.getMerchant() : "Unknown");
                expense.setCategory(aiBody.getCategory() != null ? aiBody.getCategory() : "General");
                expense.setType(aiBody.getType() != null ? aiBody.getType() : "Spent"); // Default, unless we improve AI
                                                                                        // to detect credit
                expense.setNotes(aiBody.getNotes() != null ? aiBody.getNotes() : "Parsed by Gemini AI");
                expense.setCurrency(aiBody.getCurrency() != null ? aiBody.getCurrency() : "INR");

                System.out.println("Open API extracted expense: " + expense);
                // If AI returns null amount, consider it a failure and fallback
                if (expense.getAmount() == null) {
                    throw new Exception("Open returned null amount");
                }
            } else {
                throw new Exception("Open API returned error status or empty body");
            }
        } catch (Exception e) {
            System.out.println("Open API extraction failed (" + e.getMessage() + "). Falling back to regex.");
            extractionMethod = "Regex Fallback";
            // 2. Fallback Method: Regex
            expense = extractExpense(normalizedSubject, rawBody);
            System.out.println("Regex extracted expense: " + expense);
        }

        if (expense != null) {
            expense.setUser(emailLog.getUser());
            expense.setSource("Mail (" + extractionMethod + ")");
            expense.setDate(emailLog.getReceivedAt());

            // Currency conversion removed by user request (static fallback on frontend)
            // expense.setAmountInInr(...);

            expenseRepository.save(expense);
            System.out.println("Parsed and saved expense via " + extractionMethod + ": " + expense.getAmount() + " for "
                    + expense.getMerchant());

            // 1. Try to pay an existing bill
            boolean matched = billService.processExpenseForBillPayment(expense);

            // 2. If not matched, check if we should AUTO-CREATE a new bill subscription
            if (!matched) {
                checkForRecurringBill(expense, rawSubject + " " + rawBody);
            }

        } else {
            System.out.println("Could not extract expense from email: " + emailLog.getId());
        }
    }

    private void checkForRecurringBill(Expense expense, String content) {
        String lowerContent = content.toLowerCase();
        if (lowerContent.contains("auto pay") || lowerContent.contains("auto-pay")
                || lowerContent.contains("subscription") || lowerContent.contains("recurring")) {

            // Check if bill already exists
            java.util.List<com.antigravity.expensetracker.model.Bill> existing = billRepository
                    .findByUserId(expense.getUser().getId());
            boolean exists = existing.stream().anyMatch(b -> b.getMerchant().equalsIgnoreCase(expense.getMerchant()));

            if (!exists) {
                com.antigravity.expensetracker.model.Bill newBill = new com.antigravity.expensetracker.model.Bill();
                newBill.setUser(expense.getUser());
                newBill.setMerchant(expense.getMerchant());
                newBill.setAmount(expense.getAmount());
                newBill.setCategory(expense.getCategory());
                newBill.setNote("Auto-detected from email");
                newBill.setType("Debit");
                newBill.setFrequency("MONTHLY"); // Default guess
                // Set due date to next month approx
                newBill.setDueDate(expense.getDate().plusMonths(1));

                billRepository.save(newBill);
                System.out.println("Auto-created Bill for " + expense.getMerchant());
            }
        }
    }

    private Expense extractExpense(String subject, String rawBody) {
        String regex = "(?:INR|Rs\\.?|₹)\\s*([\\d,.]+)\\s+(?:was\\s+)?(debited|credited|spent)(?:\\s+from|\\s+to|\\s+on)?\\s*(.*)";
        Pattern pattern = Pattern.compile(regex, Pattern.CASE_INSENSITIVE);
        Matcher matcher = pattern.matcher(subject);

        if (matcher.find()) {
            try {
                String amountStr = matcher.group(1).replace(",", "");
                String typeStr = matcher.group(2);
                String remainder = matcher.group(3);

                BigDecimal amount = new BigDecimal(amountStr);

                String type;
                if (typeStr.equalsIgnoreCase("credited")) {
                    type = "Credited";
                } else if (typeStr.equalsIgnoreCase("debited")) {
                    type = "Debited";
                } else {
                    type = "Spent";
                }

                String merchant = "Unknown";
                String notes = "Auto-parsed from Email Log";

                if (type.equals("Credited")) {
                    merchant = "Credit to Account";
                }

                if (!type.equals("Credited")) {
                    if (remainder.toLowerCase().contains("your a/c")
                            || remainder.toLowerCase().contains("credit card")) {
                        merchant = "Bank Transaction";
                    } else if (remainder.toLowerCase().contains("towards")) {
                        merchant = remainder.split("towards")[1].trim().split("\\s|\\.")[0];
                    } else {
                        merchant = "Bank Transaction";
                    }
                }

                Pattern merchantPattern = Pattern.compile("Merchant Name[:\\s]+([^\\n\\r]+)", Pattern.CASE_INSENSITIVE);
                Matcher merchantMatcher = merchantPattern.matcher(rawBody);

                Pattern fullUpiPattern = Pattern.compile("(UPI\\/(?:P2A|P2M|P2P)\\/[^\\n\\r]+)",
                        Pattern.CASE_INSENSITIVE);
                Matcher fullUpiMatcher = fullUpiPattern.matcher(rawBody);

                boolean merchantFoundByName = false;
                if (merchantMatcher.find()) {
                    String found = merchantMatcher.group(1).trim();
                    if (found.length() > 1 && found.length() < 50) {
                        merchant = found;
                        merchantFoundByName = true;
                    }
                }

                if (fullUpiMatcher.find()) {
                    String matchedUpi = fullUpiMatcher.group(1).replaceAll("<[^>]+>", "").trim();
                    notes = matchedUpi;

                    if (!merchantFoundByName) {
                        String[] parts = notes.split("/");
                        if (parts.length >= 4) {
                            String potentialMerchant = parts[3].trim();
                            if (potentialMerchant.length() > 1 && potentialMerchant.length() < 100) {
                                merchant = potentialMerchant;
                            }
                        }
                    }
                }

                Expense expense = new Expense();
                expense.setAmount(amount);
                expense.setCurrency("INR");
                expense.setMerchant(merchant);
                expense.setType(type);

                if (type.equals("Transfer")) {
                    expense.setCategory("Transaction");
                } else if (merchant.equalsIgnoreCase("Bank Transaction")) {
                    expense.setCategory("Transaction");
                } else {
                    String cat = categorize(merchant, remainder);

                    if (notes.startsWith("UPI") && cat.equals("General")) {
                        expense.setCategory("Transaction");
                    } else if (type.equals("Spent") && cat.equals("General")) {
                        expense.setCategory("Utilities");
                    } else {
                        expense.setCategory(cat);
                    }
                }

                expense.setNotes(notes);
                return expense;

            } catch (Exception e) {
                System.out.println("Error parsing matched expense: " + e.getMessage());
                return null;
            }
        }
        return null;
    }

    private String categorize(String merchant, String context) {
        String m = (merchant + " " + context).toLowerCase();

        if (m.contains("dreamplug") || m.contains("cred "))
            return "Transaction";

        if (m.contains("swiggy") || m.contains("zomato") || m.contains("food") || m.contains("restaurant")
                || m.contains("starbucks") || m.contains("cafe") || m.contains("coffee") || m.contains("tea")
                || m.contains("burger") || m.contains("pizza") || m.contains("dominos") || m.contains("kfc")
                || m.contains("mcdonalds") || m.contains("subway") || m.contains("dining") || m.contains("eat"))
            return "Food";

        if (m.contains("uber") || m.contains("ola") || m.contains("rapido") || m.contains("redbus")
                || m.contains("irctc") || m.contains("railway") || m.contains("metro") || m.contains("train")
                || m.contains("flight") || m.contains("indigo") || m.contains("vistara") || m.contains("air india")
                || m.contains("makemytrip") || m.contains("goibibo") || m.contains("yatra") || m.contains("booking")
                || m.contains("petrol") || m.contains("fuel") || m.contains("diesel") || m.contains("shell")
                || m.contains("hpcl") || m.contains("bpcl") || m.contains("ioc")
                || m.contains("fastag") || m.contains("transport")) {
            System.out.println("DEBUG: Categorized as Travel because of string [" + m + "]");
            return "Travel";
        }

        if (m.contains("bigbasket") || m.contains("blinkit") || m.contains("zepto") || m.contains("instamart")
                || m.contains("dmart") || m.contains("grocery") || m.contains("supermarket") || m.contains("market")
                || m.contains("fresh") || m.contains("vegetable") || m.contains("fruit") || m.contains("milk")
                || m.contains("dairy"))
            return "Groceries";

        if (m.contains("amazon") || m.contains("flipkart") || m.contains("myntra") || m.contains("ajio")
                || m.contains("meesho") || m.contains("nykaa") || m.contains("reliance") || m.contains("croma")
                || m.contains("tata") || m.contains("retail") || m.contains("mart") || m.contains("store")
                || m.contains("decathlon") || m.contains("ikea") || m.contains("zudio") || m.contains("westside")
                || m.contains("pantaloons") || m.contains("cloth") || m.contains("fashion") || m.contains("shopping"))
            return "Shopping";

        if (m.contains("netflix") || m.contains("spotify") || m.contains("hotstar") || m.contains("prime video")
                || m.contains("youtube") || m.contains("movie") || m.contains("cinema") || m.contains("pvr")
                || m.contains("inox") || m.contains("bookmyshow") || m.contains("game") || m.contains("steam")
                || m.contains("playstation") || m.contains("entertainment"))
            return "Entertainment";

        // Utilities & Bills
        if (m.contains("bill") || m.contains("recharge") || m.contains("airtel") || m.contains("jio")
                || m.contains("bsnl") || m.contains("vodafone") || m.contains("broadband")
                || m.contains("hathway") || m.contains("electricity") || m.contains("bescom")
                || m.contains("water") || m.contains("gas") || m.contains("utility")) {
            System.out.println("DEBUG: Categorized as Utilities because of string [" + m + "]");
            return "Utilities";
        }

        if (m.contains("hospital") || m.contains("pharmacy") || m.contains("medicine") || m.contains("medical")
                || m.contains("apollo") || m.contains("1mg") || m.contains("pharmeasy") || m.contains("practo")
                || m.contains("doctor") || m.contains("clinic") || m.contains("lab") || m.contains("diagnostic")
                || m.contains("health"))
            return "Health";

        if (m.contains("investment") || m.contains("mutual fund") || m.contains("sip") || m.contains("zerodha")
                || m.contains("groww") || m.contains("upstox") || m.contains("stock") || m.contains("ppf")
                || m.contains("lic") || m.contains("insurance") || m.contains("premium") || m.contains("policy"))
            return "Investment";

        return "General";
    }
}
