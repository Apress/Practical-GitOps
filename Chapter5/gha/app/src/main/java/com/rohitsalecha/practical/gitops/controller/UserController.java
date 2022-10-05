package com.rohitsalecha.practical.gitops.controller;

import com.rohitsalecha.practical.gitops.model.*;
import com.rohitsalecha.practical.gitops.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.validation.Valid;

@Controller
@RequestMapping("/users/")
public class UserController {

    private final UserRepository userRepository;

    @Autowired
    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("signup")
    public String showSignUpForm(User user) {
        return "add-user";
    }

    @GetMapping("list")
    public String showUpdateForm(Model model) {
        model.addAttribute("users", userRepository.findAll());
        return "index";
    }

    @PostMapping("add")
    public String adduser(@Valid User user, BindingResult result, Model model) {
        if (result.hasErrors()) {
            return "add-user";
        }

        userRepository.save(user);
        return "redirect:list";
    }

    @GetMapping("edit/{id}")
    public String showUpdateForm(@PathVariable("id") long id, Model model) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Invalid user Id:" + id));
        model.addAttribute("user", user);
        return "update-user";
    }

    @PostMapping("update/{id}")
    public String updateuser(@PathVariable("id") long id, @Valid User user, BindingResult result,
        Model model) {
        if (result.hasErrors()) {
            user.setId(id);
            return "update-user";
        }

        userRepository.save(user);
        model.addAttribute("users", userRepository.findAll());
        return "index";
    }

    @GetMapping("delete/{id}")
    public String deleteuser(@PathVariable("id") long id, Model model) {
        User user = userRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Invalid user Id:" + id));
        userRepository.delete(user);
        model.addAttribute("users", userRepository.findAll());
        return "index";
    }
}
