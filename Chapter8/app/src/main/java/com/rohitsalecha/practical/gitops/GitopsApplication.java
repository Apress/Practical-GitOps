package com.rohitsalecha.practical.gitops;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class GitopsApplication {

    static final Logger logger = LoggerFactory.getLogger(GitopsApplication.class);

	public static void main(String[] args) {
		logger.info("Before Application startup");
		
		SpringApplication.run(GitopsApplication.class, args);

		logger.debug("Application Starting in debug with {} arguments", args.length);
		logger.info("Application Starting with {} arguments.", args.length);
		
	}

}
