package com.vunven.backend.controller;

import com.vunven.backend.dto.TransactionRequest;
import com.vunven.backend.entity.Transaction;
import com.vunven.backend.repository.TransactionRepository;
import com.vunven.backend.service.TransactionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/transactions")
@CrossOrigin(origins = "*")
public class TransactionController {
    @Autowired
    private TransactionRepository transactionRepository;

    @Autowired
    private TransactionService transactionService;

    @GetMapping
    public List<Transaction> getAllTransactions(@RequestParam(required = false, defaultValue = "user123") String userId) {
        return transactionRepository.findByWalletUserId(userId);
    }

    @PostMapping
    public Transaction createTransaction(@RequestBody TransactionRequest request) {
        return transactionService.createTransaction(request);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteTransaction(@PathVariable String id) {
        try {
            transactionService.deleteTransaction(id);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }
}
