package com.antigravity.expensetracker.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class ExpenseExtractionResponse {
    private BigDecimal amount;
    private String currency;
    private String merchant;
    private String date;
    private String category;
    private String paymentMethod;
    private String type;
    private String notes;
    private Double confidence;
    private boolean error;
}
