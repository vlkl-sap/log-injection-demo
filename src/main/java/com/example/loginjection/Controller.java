package com.example.loginjection;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;

@RestController
public class Controller {

    @GetMapping("/endpoint")
    public String endpoint(@RequestParam("data") String s) {
        return "OK";
    }
}
