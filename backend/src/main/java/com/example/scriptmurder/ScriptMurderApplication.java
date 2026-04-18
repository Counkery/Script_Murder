package com.example.scriptmurder;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ScriptMurderApplication {

    public static void main(String[] args) {
        SpringApplication.run(ScriptMurderApplication.class, args);
    }
}

