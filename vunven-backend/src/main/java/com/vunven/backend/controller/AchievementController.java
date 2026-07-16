package com.vunven.backend.controller;

import com.vunven.backend.entity.Achievement;
import com.vunven.backend.entity.UserAchievement;
import com.vunven.backend.entity.User;
import com.vunven.backend.repository.AchievementRepository;
import com.vunven.backend.repository.UserAchievementRepository;
import com.vunven.backend.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/achievements")
@CrossOrigin(origins = "*")
public class AchievementController {
    @Autowired
    private AchievementRepository achievementRepository;

    @Autowired
    private UserAchievementRepository userAchievementRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<Achievement> getAllAchievements() {
        return achievementRepository.findAll();
    }

    @GetMapping("/user/{userId}")
    public List<UserAchievement> getUserAchievements(@PathVariable String userId) {
        return userAchievementRepository.findByUserId(userId);
    }

    @PostMapping("/unlock")
    public ResponseEntity<UserAchievement> unlockAchievement(@RequestParam String userId, @RequestParam String achievementId) {
        User user = userRepository.findById(userId).orElse(null);
        Achievement achievement = achievementRepository.findById(achievementId).orElse(null);
        if (user == null || achievement == null) {
            return ResponseEntity.badRequest().build();
        }

        UserAchievement ua = UserAchievement.builder()
                .user(user)
                .achievement(achievement)
                .unlockedAt(LocalDateTime.now())
                .build();
        return ResponseEntity.ok(userAchievementRepository.save(ua));
    }
}
