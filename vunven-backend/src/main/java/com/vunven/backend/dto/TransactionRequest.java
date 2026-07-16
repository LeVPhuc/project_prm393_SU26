package com.vunven.backend.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class TransactionRequest {
    private String id;
    private String walletId;
    private String categoryId;
    private String categoryEnum;
    private String challengeId;
    private Double amount;
    private String type; // income, expense
    private String title;
    private String note;
    private LocalDateTime date;
}
