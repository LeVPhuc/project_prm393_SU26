package com.vunven.backend.controller;

import com.vunven.backend.entity.Wallet;
import com.vunven.backend.repository.WalletRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/wallets")
@CrossOrigin(origins = "*")
public class WalletController {
    @Autowired
    private WalletRepository walletRepository;

    @GetMapping
    public List<Wallet> getAllWallets(@RequestParam(required = false, defaultValue = "user123") String userId) {
        return walletRepository.findByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Wallet> getWalletById(@PathVariable String id) {
        return walletRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Wallet createWallet(@RequestBody Wallet wallet) {
        return walletRepository.save(wallet);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Wallet> updateWallet(@PathVariable String id, @RequestBody Wallet walletDetails) {
        return walletRepository.findById(id).map(wallet -> {
            wallet.setName(walletDetails.getName());
            wallet.setBalance(walletDetails.getBalance());
            wallet.setFrozenBalance(walletDetails.getFrozenBalance());
            wallet.setIcon(walletDetails.getIcon());
            wallet.setColorIndex(walletDetails.getColorIndex());
            wallet.setType(walletDetails.getType());
            wallet.setIsDefault(walletDetails.getIsDefault());
            return ResponseEntity.ok(walletRepository.save(wallet));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteWallet(@PathVariable String id) {
        return walletRepository.findById(id).map(wallet -> {
            walletRepository.delete(wallet);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
