package com.vunven.backend.controller;

import com.vunven.backend.entity.Challenge;
import com.vunven.backend.repository.ChallengeRepository;
import com.vunven.backend.service.ChallengeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/challenges")
@CrossOrigin(origins = "*")
public class ChallengeController {
    @Autowired
    private ChallengeRepository challengeRepository;

    @Autowired
    private ChallengeService challengeService;

    @GetMapping
    public List<Challenge> getAllChallenges(@RequestParam(required = false, defaultValue = "user123") String userId) {
        return challengeRepository.findByUserId(userId);
    }

    @GetMapping("/{id}")
    public ResponseEntity<Challenge> getChallengeById(@PathVariable String id) {
        return challengeRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Challenge createChallenge(@RequestBody Challenge challenge) {
        return challengeService.createChallenge(challenge);
    }

    @PutMapping("/{id}/status")
    public ResponseEntity<Challenge> updateChallengeStatus(@PathVariable String id, @RequestParam String status) {
        try {
            Challenge updated = challengeService.updateChallengeStatus(id, status);
            return ResponseEntity.ok(updated);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteChallenge(@PathVariable String id) {
        return challengeRepository.findById(id).map(challenge -> {
            challengeRepository.delete(challenge);
            return ResponseEntity.ok().build();
        }).orElse(ResponseEntity.notFound().build());
    }
}
