package com.example.loginjection;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestParam;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class Controller {

    @GetMapping("/endpoint")
    public String endpoint(@RequestParam("data") String s) {
        Logger logger = LoggerFactory.getLogger(Controller.class);
        logger.info(s);
        return "OK";
    }
}
