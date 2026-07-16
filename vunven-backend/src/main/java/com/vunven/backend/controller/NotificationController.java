package com.vunven.backend.controller;

import com.vunven.backend.entity.Notification;
import com.vunven.backend.repository.NotificationRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/notifications")
@CrossOrigin(origins = "*")
public class NotificationController {
    @Autowired
    private NotificationRepository notificationRepository;

    @GetMapping
    public List<Notification> getNotifications(@RequestParam(required = false, defaultValue = "user123") String userId) {
        return notificationRepository.findByUserIdOrderByScheduledAtDesc(userId);
    }

    @PutMapping("/{id}/read")
    public ResponseEntity<Notification> markAsRead(@PathVariable String id) {
        return notificationRepository.findById(id).map(not -> {
            not.setStatus("read");
            return ResponseEntity.ok(notificationRepository.save(not));
        }).orElse(ResponseEntity.notFound().build());
    }
}
