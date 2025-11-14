package com.example.config;

import com.example.entity.User;
import com.example.service.UserService;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataInitializer {

    @Bean
    public CommandLineRunner initData(UserService userService) {
        return args -> {
            // 관리자 계정 생성
            userService.createUser("admin", "admin123", "ADMIN");
            // 일반 사용자 계정 생성
            userService.createUser("user", "user123", "USER");
        };
    }
} 