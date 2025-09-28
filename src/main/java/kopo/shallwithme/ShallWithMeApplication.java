package kopo.shallwithme;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class ShallWithMeApplication {

    public static void main(String[] args) {
        SpringApplication.run(ShallWithMeApplication.class, args);
    }

}