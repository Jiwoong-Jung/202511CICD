package com.example.controller;

import com.example.entity.User;
import com.example.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
public class HomeController {

    @Autowired
    private UserService userService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("currentPage", "home");
        return "home";
    }

    @GetMapping("/login")
    public String login(Model model) {
        model.addAttribute("currentPage", "login");
        return "login";
    }

    @GetMapping("/register")
    public String register(Model model) {
        model.addAttribute("currentPage", "register");
        return "register";
    }

    @PostMapping("/register")
    public String registerUser(@RequestParam String username,
                             @RequestParam String password,
                             @RequestParam String confirmPassword,
                             RedirectAttributes redirectAttributes) {
        // 비밀번호 확인
        if (!password.equals(confirmPassword)) {
            redirectAttributes.addFlashAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "redirect:/register";
        }

        try {
            // 사용자 생성
            userService.createUser(username, password, "USER");
            
            redirectAttributes.addFlashAttribute("success", "회원가입이 완료되었습니다. 로그인해주세요.");
            return "redirect:/login";
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "회원가입 중 오류가 발생했습니다. 다른 사용자명을 시도해주세요.");
            return "redirect:/register";
        }
    }

    @GetMapping("/admin")
    public String admin(Model model) {
        model.addAttribute("currentPage", "admin");
        return "admin";
    }
} 